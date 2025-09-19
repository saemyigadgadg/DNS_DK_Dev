/**
 * CometD 3.1.0 구현
 * 기본적인 pub/sub 메시징 기능 제공
 */
(function(window) {
    if (!window.WebSocket && !window.MozWebSocket) {
        throw 'WebSocket not supported';
    }

    var org = window.org = window.org || {};
    org.cometd = org.cometd || {};

    function CometD() {
        var _connected = false;
        var _handshook = false;
        var _clientId = null;
        var _batch = 0;
        var _messageId = 0;
        var _subscriptions = {};
        var _transport = null;

        this.init = function(options) {
            var defaults = {
                url: window.location.protocol + '//' + window.location.host + '/cometd/44.0',
                logLevel: 'info',
                appendMessageTypeToURL: false
            };

            this.configure(Object.assign({}, defaults, options));
            return this;
        };

        this.configure = function(configuration) {
            _config = configuration;
            return this;
        };

        this.handshake = function(handshakeProps) {
            var message = {
                channel: '/meta/handshake',
                version: '1.0',
                minimumVersion: '1.0',
                supportedConnectionTypes: ['long-polling'],
                advice: {
                    timeout: 60000,
                    interval: 0
                }
            };

            if (handshakeProps) {
                Object.assign(message, handshakeProps);
            }

            var xhr = new XMLHttpRequest();
            xhr.open('POST', _config.url, true);
            xhr.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
            
            // Salesforce 세션 ID 추가
            if (typeof SfdcApp !== 'undefined' && SfdcApp.projectOneNavigator) {
                xhr.setRequestHeader('Authorization', 'OAuth ' + SfdcApp.projectOneNavigator.getSessionId());
            }

            xhr.onload = function() {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    if (response[0].successful) {
                        _handshook = true;
                        _clientId = response[0].clientId;
                        _connected = true;
                    }
                }
            };

            xhr.send(JSON.stringify([message]));
        };

        this.subscribe = function(channel, callback) {
            if (!_handshook) {
                throw 'Must handshake before subscribing';
            }

            var message = {
                channel: '/meta/subscribe',
                clientId: _clientId,
                subscription: channel,
                id: ++_messageId
            };

            var subscriptionId = 'sub_' + Math.random().toString(36).substr(2, 9);
            _subscriptions[subscriptionId] = {
                channel: channel,
                callback: callback
            };

            var xhr = new XMLHttpRequest();
            xhr.open('POST', _config.url, true);
            xhr.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');

            if (typeof SfdcApp !== 'undefined' && SfdcApp.projectOneNavigator) {
                xhr.setRequestHeader('Authorization', 'OAuth ' + SfdcApp.projectOneNavigator.getSessionId());
            }

            xhr.send(JSON.stringify([message]));
            return subscriptionId;
        };

        this.disconnect = function() {
            _connected = false;
            _handshook = false;
            _clientId = null;
        };

        this.isDisconnected = function() {
            return !_connected;
        };
    }

    org.cometd.CometD = CometD;
})(window); 