/**
 *
 * @author mdmye
 */
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.Base64;
 
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
 
public class AES {
 
    private static SecretKeySpec secretKey;
    private static byte[] key;
 
    public static void setKey(String myKey)
    {
        MessageDigest sha = null;
        try {
            key = myKey.getBytes("UTF-8");
            sha = MessageDigest.getInstance("SHA-1");
            key = sha.digest(key);
            key = Arrays.copyOf(key, 16);
            secretKey = new SecretKeySpec(key, "AES");
        }
        catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }
 
    public static String encrypt(String strToEncrypt, String secret)
    {
        try
        {
            setKey(secret);
            Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
            cipher.init(Cipher.ENCRYPT_MODE, secretKey);
            return Base64.getEncoder().encodeToString(cipher.doFinal(strToEncrypt.getBytes("UTF-8")));
        }
        catch (Exception e)
        {
            System.out.println("Error while encrypting: " + e.toString());
        }
        return null;
    }
    
    public static String encryptFile(String fileName, String secretKey)throws Exception
    {
        String originalString = "";
        originalString = new String(Files.readAllBytes(Paths.get(fileName)));
        
        String encryptedString = AES.encrypt(originalString, secretKey);
        
        File tmpFile = File.createTempFile("test", ".tmp");
        FileWriter writer = new FileWriter(tmpFile);
        writer.write(encryptedString);
        writer.close();
 
        BufferedReader reader = new BufferedReader(new FileReader(tmpFile));
        //assertEquals(encryptedString, reader.readLine());
        reader.close();
        
        return tmpFile.getPath();
    }
 
    public static String decrypt(String strToDecrypt, String secret)
    {
        try
        {
            setKey(secret);
            Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5PADDING");
            cipher.init(Cipher.DECRYPT_MODE, secretKey);
            return new String(cipher.doFinal(Base64.getDecoder().decode(strToDecrypt)));
        }
        catch (Exception e)
        {
            System.out.println("Error while decrypting: " + e.toString());
        }
        return null;
    }
    
    public static String decryptFile(String fileName, String secretKey)throws Exception
    {
        String encryptedString = "";
        encryptedString = new String(Files.readAllBytes(Paths.get(fileName)));
        
        String decryptedString = AES.decrypt(encryptedString, secretKey);
        
        File tmpFile = File.createTempFile("test", ".tmp");
        FileWriter writer = new FileWriter(tmpFile);
        writer.write(decryptedString);
        writer.close();
 
        BufferedReader reader = new BufferedReader(new FileReader(tmpFile));
        //assertEquals(encryptedString, reader.readLine());
        reader.close();
        
        return tmpFile.getPath();
    }
}
