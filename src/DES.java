
/**
 * Code base from https://examples.javacodegeeks.com/core-java/crypto/encrypt-decrypt-string-with-des/
 * Then edited to suit my needs
 */

//package com.javacodegeeks.snippets.core;
import com.sun.xml.internal.messaging.saaj.packaging.mime.util.BASE64DecoderStream;
import com.sun.xml.internal.messaging.saaj.packaging.mime.util.BASE64EncoderStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;

//import com.sun.mail.util.BASE64DecoderStream;
//import com.sun.mail.util.BASE64EncoderStream;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DES {

    private static Cipher ecipher;
    private static Cipher dcipher;

    private static SecretKey key;

    public static void main(String[] args) {

        try {
            String encrypted = encrypt("This is a classified message!");
            System.out.println(encrypted);
            String decrypted = decrypt(encrypted);
            System.out.println("Decrypted: " + decrypted);
        } catch (NoSuchAlgorithmException ex) {
            Logger.getLogger(DES.class.getName()).log(Level.SEVERE, null, ex);
        }

    }

    public static String encrypt(String str) throws NoSuchAlgorithmException {

        try {
            // generate secret key using DES algorithm
            key = KeyGenerator.getInstance("DES").generateKey();

            try {
                ecipher = Cipher.getInstance("DES");
            } catch (NoSuchPaddingException ex) {
                Logger.getLogger(DES.class.getName()).log(Level.SEVERE, null, ex);
            }
            try {
                dcipher = Cipher.getInstance("DES");
            } catch (NoSuchPaddingException ex) {
                Logger.getLogger(DES.class.getName()).log(Level.SEVERE, null, ex);
            }

            // initialize the ciphers with the given key
            ecipher.init(Cipher.ENCRYPT_MODE, key);
            dcipher.init(Cipher.DECRYPT_MODE, key);

            try {
                // encode the string into a sequence of bytes using the named charset
                // storing the result into a new byte array.
                byte[] utf8 = str.getBytes("UTF8");
                byte[] enc = ecipher.doFinal(utf8);

                // encode to base64
                enc = BASE64EncoderStream.encode(enc);
                return new String(enc);
            } catch (Exception e) {
                e.printStackTrace();
            }
        } catch (InvalidKeyException ex) {
            Logger.getLogger(DES.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    public static String encryptFile(String fileName) throws NoSuchAlgorithmException, IOException {

        String encryptedText = "";

        try {
            // generate secret key using DES algorithm
            key = KeyGenerator.getInstance("DES").generateKey();

            try {
                ecipher = Cipher.getInstance("DES");
            } catch (NoSuchPaddingException ex) {
                Logger.getLogger(DES.class.getName()).log(Level.SEVERE, null, ex);
            }
            try {
                dcipher = Cipher.getInstance("DES");
            } catch (NoSuchPaddingException ex) {
                Logger.getLogger(DES.class.getName()).log(Level.SEVERE, null, ex);
            }

            // initialize the ciphers with the given key
            ecipher.init(Cipher.ENCRYPT_MODE, key);
            dcipher.init(Cipher.DECRYPT_MODE, key);

            try {
                // encode the string into a sequence of bytes using the named charset
                // storing the result into a new byte array.
                //System.out.println("File Name is: " + fileName); debugging
                String originalString = new String(Files.readAllBytes(Paths.get(fileName)));
                //System.out.println("String to be encrypted: " + originalString); debugging
                byte[] utf8 = originalString.getBytes("UTF8");
                byte[] enc = ecipher.doFinal(utf8);

                // encode to base64
                enc = BASE64EncoderStream.encode(enc);
                encryptedText = new String(enc);

                File tmpFile = File.createTempFile("test", ".tmp");
                FileWriter writer = new FileWriter(tmpFile);
                writer.write(new String(enc));
                writer.close();

                BufferedReader reader = new BufferedReader(new FileReader(tmpFile));
                //assertEquals(encryptedString, reader.readLine());
                reader.close();

                return tmpFile.getPath();
            } catch (Exception e) {
                e.printStackTrace();
            }
        } catch (InvalidKeyException ex) {
            Logger.getLogger(DES.class.getName()).log(Level.SEVERE, null, ex);
        }

        return null;

    }

    public static String decrypt(String str) throws NoSuchAlgorithmException {

        try {
            // generate secret key using DES algorithm
            //key = KeyGenerator.getInstance("DES").generateKey();

            try {
                ecipher = Cipher.getInstance("DES");
            } catch (NoSuchPaddingException ex) {
                Logger.getLogger(DES.class.getName()).log(Level.SEVERE, null, ex);
            }
            try {
                dcipher = Cipher.getInstance("DES");
            } catch (NoSuchPaddingException ex) {
                Logger.getLogger(DES.class.getName()).log(Level.SEVERE, null, ex);
            }

            //Initialize the ciphers with the given key
            ecipher.init(Cipher.ENCRYPT_MODE, key);
            dcipher.init(Cipher.DECRYPT_MODE, key);

            try {
                // decode with base64 to get bytes
                byte[] dec = BASE64DecoderStream.decode(str.getBytes());
                byte[] utf8 = dcipher.doFinal(dec);

                // create new string based on the specified charset
                return new String(utf8, "UTF8");
            } catch (Exception e) {
                e.printStackTrace();
            }
        } catch (InvalidKeyException ex) {
            Logger.getLogger(DES.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }


    public static String decryptFile(String fileName) throws NoSuchAlgorithmException, IOException {

        try {
            // generate secret key using DES algorithm
            //key = KeyGenerator.getInstance("DES").generateKey();

            try {
                ecipher = Cipher.getInstance("DES");
            } catch (NoSuchPaddingException ex) {
                Logger.getLogger(DES.class.getName()).log(Level.SEVERE, null, ex);
            }
            try {
                dcipher = Cipher.getInstance("DES");
            } catch (NoSuchPaddingException ex) {
                Logger.getLogger(DES.class.getName()).log(Level.SEVERE, null, ex);
            }

            //Initialize the ciphers with the given key
            ecipher.init(Cipher.ENCRYPT_MODE, key);
            dcipher.init(Cipher.DECRYPT_MODE, key);
            
            String str = new String(Files.readAllBytes(Paths.get(fileName)));

            try {
                // decode with base64 to get bytes
                byte[] dec = BASE64DecoderStream.decode(str.getBytes());
                byte[] utf8 = dcipher.doFinal(dec);
                String originalString = new String(utf8, "UTF8");
                
                File tmpFile = File.createTempFile("test", ".tmp");
                FileWriter writer = new FileWriter(tmpFile);
                writer.write(originalString);
                writer.close();

                BufferedReader reader = new BufferedReader(new FileReader(tmpFile));
                //assertEquals(encryptedString, reader.readLine());
                reader.close();

                return tmpFile.getPath();

                // create new string based on the specified charset
                //return new String(utf8, "UTF8");
                
                
            } catch (Exception e) {
                e.printStackTrace();
            }
        } catch (InvalidKeyException ex) {
            Logger.getLogger(DES.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }
}