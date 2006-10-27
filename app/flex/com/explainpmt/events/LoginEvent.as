package com.explainpmt.events
{
    import flash.events.Event;

    public class LoginEvent extends Event
    {
        public const LOGIN:String = "login";
        
        public var user:XML;
        
        public function LoginEvent(user:XML):void {
            super(LOGIN);
            this.user = user;
        }
    }
}