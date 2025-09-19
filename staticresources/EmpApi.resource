window.EmpApi = function() {
    var cometd = new org.cometd.CometD();
    
    function _connect() {
        cometd.configure({
            url: window.location.protocol + '//' + window.location.hostname + '/cometd/44.0/',
            requestHeaders: { Authorization: 'OAuth {!$API.Session_ID}' }
        });
        
        cometd.handshake(function(handshakeReply) {
            if (handshakeReply.successful) {
                console.log('Connected to CometD.');
            } else {
                console.error('Failed to connect to CometD:', handshakeReply);
            }
        });
    }
    
    this.subscribe = function(channel, replayId, callback) {
        if (!cometd.isDisconnected()) {
            _connect();
        }
        
        var subscription = cometd.subscribe(channel, function(message) {
            callback(message.data);
        });
        
        return subscription;
    };
    
    this.unsubscribe = function(subscription) {
        cometd.unsubscribe(subscription);
    };
    
    _connect();
}; 