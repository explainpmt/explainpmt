package com.explainpmt.model
{
    public class User
    {
        private var _id:uint;
        private var _username:String;
        private var _firstName:String;
        private var _lastName:String;
        private var _email:String;
        private var _password:String;
        private var _updatedAt:Date;
        private var _createdAt:Date;
        private var _admin:Boolean;
        
        public function User(data:XML) {
            _id = uint(data.id);
            _username = data.username;
            _firstName = data.first_name;
            _lastName = data.last_name;
            _email = data.email;
            _password = data.password;
            _updatedAt = new Date(Date.parse(data.updated_at));
            _createdAt = new Date(Date.parse(data.created_at));
            _admin = (data.admin == 'true') ? true : false;
        }
        
        public function get id():uint {
            return _id;
        }
        
        public function get username():String {
            return _username;
        }
        
        public function get firstName():String {
            return _firstName;
        }
        
        public function get lastName():String {
            return _lastName;
        }
        
        public function get email():String {
            return _email;
        }
        
        public function get updatedAt():Date {
            return _updatedAt;
        }
        
        public function get createdAt():Date {
            return _createdAt;
        }
        
        public function isAdmin():Boolean {
            return _admin;
        }
    }
}