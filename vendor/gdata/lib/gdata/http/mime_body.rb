# Copyright (C) 2008 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module GData
  module HTTP
  
    # Class acts as a virtual file handle to a MIME multipart message body
    class MimeBody
      
      # The MIME boundary being used.
      attr_reader :boundary
      
      # All fields are required, the entry should be a string and is assumed
      # to be XML.
      def initialize(entry, file, file_mime_type)
        @boundary = "END_OF_PART_#{rand(64000)}"
        entry = wrap_entry(entry, file_mime_type)
        closing_boundary = MimeBodyString.new("\r\n--#{@boundary}--")
        @parts = [entry, file, closing_boundary]
        @current_part = 0
      end
      
      # Implement read so that this class can be treated as a stream.
      def read(bytes_requested)
        if @current_part >= @parts.length
          return false
        end
        
        buffer = @parts[@current_part].read(bytes_requested)
        
        until buffer.length == bytes_requested
          @current_part += 1
          next_buffer = self.read(bytes_requested - buffer.length)
          break if not next_buffer
          buffer += next_buffer
        end
        
        return buffer
      end
      
      # Returns the content type of the message including boundary.
      def content_type
        return "multipart/related; boundary=\"#{@boundary}\""
      end
      
      private
      
      # Sandwiches the entry body into a MIME message
      def wrap_entry(entry, file_mime_type)
        wrapped_entry = "--#{@boundary}\r\n"
        wrapped_entry += "Content-Type: application/atom+xml\r\n\r\n"
        wrapped_entry += entry
        wrapped_entry += "\r\n--#{@boundary}\r\n"
        wrapped_entry += "Content-Type: #{file_mime_type}\r\n\r\n"
        return MimeBodyString.new(wrapped_entry)
      end
    
    end
    
    # Class makes a string into a stream-like object
    class MimeBodyString
      
      def initialize(source_string)
        @string = source_string
        @bytes_read = 0
      end
      
      # Implement read so that this class can be treated as a stream.
      def read(bytes_requested)
        if @bytes_read == @string.length
          return false
        elsif bytes_requested > @string.length - @bytes_read
          bytes_requested = @string.length - @bytes_read
        end
        
        buffer = @string[@bytes_read, bytes_requested]
        @bytes_read += bytes_requested
        
        return buffer
      end
    end
  end
end
