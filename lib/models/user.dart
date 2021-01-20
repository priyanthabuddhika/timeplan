// user class to avoid unnecessary data in firebase user

class UserModel {

  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  
  UserModel({ this.uid ,this.displayName,this.email,this.photoURL});

}