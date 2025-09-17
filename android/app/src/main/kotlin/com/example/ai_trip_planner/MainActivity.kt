package com.example.ai_trip_planner

import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import java.security.interfaces.ECPublicKey
import java.util.UUID
import javax.security.auth.x500.X500Principal
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.example.app/biometric"
    private val KEYSTORE_PROVIDER = "AndroidKeyStore"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "createBiometricKeyForUser" -> {
                    try {
                        val out = createBiometricKey()
                        result.success(out)
                    } catch (e: Exception) {
                        result.error("ERR_CREATE_KEY", e.message, null)
                    }
                }
                "signChallenge" -> {
                    val deviceId = call.argument<String>("deviceId")
                    val challengeBase64 = call.argument<String>("challenge")
                    if (deviceId == null || challengeBase64 == null) {
                        result.error("ARG_ERR", "deviceId or challenge missing", null)
                        return@setMethodCallHandler
                    }
                    signWithBiometric(deviceId, challengeBase64, result)
                }
                "openBiometricSettings" -> {
                    openBiometricSettings()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun keyAliasFor(deviceId: String) = "biokey_$deviceId"

    private fun createBiometricKey(): Map<String, String> {
        val deviceId = UUID.randomUUID().toString()
        val alias = keyAliasFor(deviceId)

        val kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, KEYSTORE_PROVIDER)
        val builder = KeyGenParameterSpec.Builder(
            alias,
            KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
        )
            .setAlgorithmParameterSpec(java.security.spec.ECGenParameterSpec("secp256r1"))
            .setDigests(KeyProperties.DIGEST_SHA256, KeyProperties.DIGEST_SHA512)
            .setUserAuthenticationRequired(true)
            .setUserAuthenticationValidityDurationSeconds(0)
            .setInvalidatedByBiometricEnrollment(true)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            // builder.setIsStrongBoxBacked(true)
        }

        kpg.initialize(builder.build())
        kpg.generateKeyPair()

        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER)
        keyStore.load(null)
        val pub = keyStore.getCertificate(alias).publicKey as ECPublicKey
        val pubBytes = pub.encoded
        val pubBase64 = Base64.encodeToString(pubBytes, Base64.NO_WRAP)

        val map = HashMap<String, String>()
        map["deviceId"] = deviceId
        map["publicKey"] = pubBase64
        map["keyAlias"] = alias
        return map
    }

    private fun signWithBiometric(deviceId: String, challengeBase64: String, result: MethodChannel.Result) {
        val alias = keyAliasFor(deviceId)
        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER)
        keyStore.load(null)
        val privateKey = keyStore.getKey(alias, null) ?: run {
            result.error("NO_KEY", "No key for alias $alias", null)
            return
        }

        val signature = Signature.getInstance("SHA256withECDSA")
        signature.initSign(privateKey as java.security.PrivateKey)

        val executor = ContextCompat.getMainExecutor(this)
        val prompt = BiometricPrompt(this, executor, object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(authResult: BiometricPrompt.AuthenticationResult) {
                try {
                    val cryptoSig = authResult.cryptoObject?.signature
                    val challengeBytes = Base64.decode(challengeBase64, Base64.NO_WRAP)
                    cryptoSig?.update(challengeBytes)
                    val sigBytes = cryptoSig?.sign()
                    val sigBase64 = Base64.encodeToString(sigBytes, Base64.NO_WRAP)
                    val resMap = HashMap<String, String>()
                    resMap["signature"] = sigBase64
                    result.success(resMap)
                } catch (e: Exception) {
                    result.error("SIGN_ERR", e.message, null)
                }
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                result.error("BIO_ERROR", "$errorCode: $errString", null)
            }
        })

        val cryptoObject = BiometricPrompt.CryptoObject(signature)
        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Confirm biometrics")
            .setSubtitle("Authenticate to sign challenge")
            .setNegativeButtonText("Cancel")
            .build()

        prompt.authenticate(promptInfo, cryptoObject)
    }

    private fun openBiometricSettings() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val intent = Intent(Settings.ACTION_FINGERPRINT_ENROLL)
                startActivity(intent)
            } else {
                val intent = Intent(Settings.ACTION_SECURITY_SETTINGS)
                startActivity(intent)
            }
        } catch (e: Exception) {
            val intent = Intent(Settings.ACTION_SETTINGS)
            startActivity(intent)
        }
    }
}
