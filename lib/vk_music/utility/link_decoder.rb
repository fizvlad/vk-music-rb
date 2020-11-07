# frozen_string_literal: true

module VkMusic
  module Utility
    # Link decoding utilities
    # TODO: This is probably a legacy utility
    class LinkDecoder
      # JS code which creates function to unmask audio URL.
      JS_CODE = <<~HEREDOC
        function vk_unmask_link(link, vk_id) {

          // Utility functions to unmask

          var audioUnmaskSource = function (encrypted) {
            if (encrypted.indexOf('audio_api_unavailable') != -1) {
              var parts = encrypted.split('?extra=')[1].split('#');

              var handled_anchor = '' === parts[1] ? '' : handler(parts[1]);

              var handled_part = handler(parts[0]);

              if (typeof handled_anchor != 'string' || !handled_part) {
                // if (typeof handled_anchor != 'string') console.warn('Handled_anchor type: ' + typeof handled_anchor);
                // if (!handled_part) console.warn('Handled_part: ' + handled_part);
                return encrypted;
              }

              handled_anchor = handled_anchor ? handled_anchor.split(String.fromCharCode(9)) : [];

              for (var func_key, splited_anchor, l = handled_anchor.length; l--;) {
                splited_anchor = handled_anchor[l].split(String.fromCharCode(11));
                func_key = splited_anchor.splice(0, 1, handled_part)[0];
                if (!utility_object[func_key]) {
                  // console.warn('Was unable to find key: ' + func_key);
                  return encrypted;
                }
                handled_part = utility_object[func_key].apply(null, splited_anchor)
              }

              if (handled_part && 'http' === handled_part.substr(0, 4)) return handled_part;
              // else console.warn('Failed unmasking: ' + handled_part);
            } else {
              // console.warn('Bad link: ' + encrypted);
            }
            return encrypted;
          }

          var handler = function (part) {
            if (!part || part.length % 4 == 1) return !1;
            for (var t, i, o = 0, s = 0, a = ''; i = part.charAt(s++);) {
              i = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN0PQRSTUVWXYZO123456789+/='.indexOf(i)
              ~i && (t = o % 4 ? 64 * t + i : i, o++ % 4) && (a += String.fromCharCode(255 & t >> (-2 * o & 6)));
            }
            return a;
          }

          var utility_object = {
            i: function(e, t) {
              return utility_object.s(e, t ^ vk_id);
            },
            s: function(e, t) {
              var n = e.length;
              if (n) {
                var i = r_func(e, t),
                  o = 0;
                for (e = e.split(''); ++o < n;)
                  e[o] = e.splice(i[n - 1 - o], 1, e[o])[0];
                e = e.join('')
              }
              return e;
            }
          };

          var r_func = function (e, t) {
            var n = e.length,
              i = [];
            if (n) {
              var o = n;
              for (t = Math.abs(t); o--;)
                t = (n * (o + 1) ^ t + o) % n,
                i[o] = t;
            }
            return i;
          }

          return audioUnmaskSource(link);
        }
      HEREDOC
      private_constant :JS_CODE

      # JS context with unmasking link
      @@js_context = ExecJS.compile(JS_CODE)

      # Unmask audio download URL
      # @param link [String] encoded link to audio. Usually looks like "https://m.vk.​com/mp3/audio_api_unavailable.mp3?extra=...".
      # @param client_id [Integer] ID of user which got this link. ID is required for decoding.
      # @return [String] audio download URL, which can be used only from current IP.
      def self.call(link, client_id)
        @@js_context.call('vk_unmask_link', link, client_id)
      end
    end
  end
end
