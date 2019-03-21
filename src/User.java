
import java.util.ArrayList;

/**
 *
 * @author mdmye
 */
public class User {
    
    //Variables
    String username;
    String password;
    
    //Constructors
    public User() {}
    
    public User(String u, String pw) {
        this.username = u;
        this.password = pw;
    }

    //Getters & Setters
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public boolean equals(User u1)
    {
       if(this == u1)
       {
           return true;
       }
       if(u1 == null || getClass() !=u1.getClass())
       {
           return false;
       }
       
       User user = (User) u1;
       return username.equals(user.username) && 
               password.equals(user.password);
    }
    
    @Override
    public String toString() {
        return "User{" + "username=" + username + ", password=" + password + '}';
    }  

}
