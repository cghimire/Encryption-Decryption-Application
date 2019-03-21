var userObj = [
	{
	username: "test",
	password: "123"
	}
]


function login() {

	var username = document.getElementById("username").value
	var password = document.getElementById("password").value

	for(i = 0; i < userObj.length; i++) {
		if(username == userObj[i].username && password == userObj[i].password) {
			window.alert("Login in succesful");
			window.open("AUD_User.html");
		} else {
			window.alert("Incorrect username or password")
		}
	}

	
}

function registerUser() {
	var registerUser = document.getElementById("newUser").value
	var registerNewPassword = document.getElementById("newPassword").value
	var newUser = {
		username: registerUser,
		password: registerNewPassword
	}

	userObj.push(newUser)
}

