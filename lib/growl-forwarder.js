"use strict";

var _ = require("lodash");
var crypto = require( "crypto" );

// a list of defined notification types
const growlTypes = [{
  label: 'info',
  dispname: 'Info'
}, {
  label: 'success',
  dispname: 'Success',
  enabled: true
}, {
  label: 'warning',
  dispname: 'Warning',
  enabled: true
},{
  label: 'error',
  dispname: 'Error',
  enabled: true
}];

module.exports = class GrowlForwarder {

  constructor(growly) {
    this.growly = growly;
    this.count = 0;
  }

  forward(notification, opts) {
    opts = opts || {};
    // Url, file path, or Buffer instance for an application icon image.
    var icon =  __dirname + '/../resources/icon.png';

    // Registers a new application with Growl
    var self = this;
    return new Promise( function(resolve, reject) {
      self.growly.register('atom-growl', icon, growlTypes, function(err) {
        if (err) {
          reject(err);
          return;
        }

        var text = _.chain([
          notification.options.description,
          notification.options.detail
        ])
        .reject(_.isEmpty)
        .join('\n\n')
        .truncate({
          'length': 128,
          'separator': ' '
        }).value();

        // Coalescing Id
        var cid = crypto
          .createHash('md5')
          .update(notification.message + text)
          .digest("hex");

        // Send to Growl
        self.growly.notify(text, {
          title: notification.message,
          label: notification.type,
          coalescingId: cid
        }, function(err, action) {
          // Handle notfication click
          if (action === 'click' && opts.onClick) {
            var event = new CustomEvent('growl_click', {
              'detail': {
                'notification': notification
              }
            });
            opts.onClick.call(this, event)
          }
        });
        self.count++;
        console.debug('🐾 Growl [%s]: %o', cid, notification);
        resolve(true);
      });
    });
  }

}
