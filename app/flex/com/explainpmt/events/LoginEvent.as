package com.explainpmt.events
{
    import flash.events.Event;
    import com.explainpmt.model.User;

    public class LoginEvent extends Event
    {
        public const LOGIN:String = "login";
        
        public var user:User;
        
        public function LoginEvent(user:User):void {
            super(LOGIN);
            this.user = user;
        }
    }
}