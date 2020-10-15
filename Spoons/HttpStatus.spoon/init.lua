--- === HttpStatus ===
---
--- Easily find the code or name for HTTP statuses

local obj={}
obj.__index = obj

-- Metadata
obj.name = 'HttpStatus'
obj.version = '0.1'
obj.author = 'James Doyle <james2doyle@gmail.com>'
obj.homepage = 'https://gist.github.com/james2doyle/8cec2b2693f7909b36587327a85055d5'
obj.license = '?'

--Array to store the statuses
local http_status_codes = {}
http_status_codes['100'] = '100 Continue'
http_status_codes['101'] = '101 Switching Protocols'
http_status_codes['102'] = '102 Processing'
http_status_codes['200'] = '200 OK'
http_status_codes['201'] = '201 Created'
http_status_codes['202'] = '202 Accepted'
http_status_codes['203'] = '203 Non-authoritative Information'
http_status_codes['204'] = '204 No Content'
http_status_codes['205'] = '205 Reset Content'
http_status_codes['206'] = '206 Partial Content'
http_status_codes['207'] = '207 Multi-Status'
http_status_codes['208'] = '208 Already Reported'
http_status_codes['226'] = '226 IM Used'
http_status_codes['300'] = '300 Multiple Choices'
http_status_codes['301'] = '301 Moved Permanently'
http_status_codes['302'] = '302 Found'
http_status_codes['303'] = '303 See Other'
http_status_codes['304'] = '304 Not Modified'
http_status_codes['305'] = '305 Use Proxy'
http_status_codes['307'] = '307 Temporary Redirect'
http_status_codes['308'] = '308 Permanent Redirect'
http_status_codes['400'] = '400 Bad Request'
http_status_codes['401'] = '401 Unauthorized'
http_status_codes['402'] = '402 Payment Required'
http_status_codes['403'] = '403 Forbidden'
http_status_codes['404'] = '404 Not Found'
http_status_codes['405'] = '405 Method Not Allowed'
http_status_codes['406'] = '406 Not Acceptable'
http_status_codes['407'] = '407 Proxy Authentication Required'
http_status_codes['408'] = '408 Request Timeout'
http_status_codes['409'] = '409 Conflict'
http_status_codes['410'] = '410 Gone'
http_status_codes['411'] = '411 Length Required'
http_status_codes['412'] = '412 Precondition Failed'
http_status_codes['413'] = '413 Payload Too Large'
http_status_codes['414'] = '414 Request-URI Too Long'
http_status_codes['415'] = '415 Unsupported Media Type'
http_status_codes['416'] = '416 Requested Range Not Satisfiable'
http_status_codes['417'] = '417 Expectation Failed'
http_status_codes['418'] = '418 I’m a teapot'
http_status_codes['421'] = '421 Misdirected Request'
http_status_codes['422'] = '422 Unprocessable Entity'
http_status_codes['423'] = '423 Locked'
http_status_codes['424'] = '424 Failed Dependency'
http_status_codes['426'] = '426 Upgrade Required'
http_status_codes['428'] = '428 Precondition Required'
http_status_codes['429'] = '429 Too Many Requests'
http_status_codes['431'] = '431 Request Header Fields Too Large'
http_status_codes['444'] = '444 Connection Closed Without Response'
http_status_codes['451'] = '451 Unavailable For Legal Reasons'
http_status_codes['499'] = '499 Client Closed Request'
http_status_codes['500'] = '500 Internal Server Error'
http_status_codes['501'] = '501 Not Implemented'
http_status_codes['502'] = '502 Bad Gateway'
http_status_codes['503'] = '503 Service Unavailable'
http_status_codes['504'] = '504 Gateway Timeout'
http_status_codes['505'] = '505 HTTP Version Not Supported'
http_status_codes['506'] = '506 Variant Also Negotiates'
http_status_codes['507'] = '507 Insufficient Storage'
http_status_codes['508'] = '508 Loop Detected'
http_status_codes['510'] = '510 Not Extended'
http_status_codes['511'] = '511 Network Authentication Required'
http_status_codes['599'] = '599 Network Connect Timeout Error'

function showMenu()
  local chooser = hs.chooser.new(function(selection)
    if selection.code ~= nil then
      -- opens the URL in the default application
      hs.urlevent.openURL('https://httpstatuses.com/' .. selection.code)
    end
  end)

  -- build a table of choices
  local choices = {}

  -- sort them by status code
  for k,v in hs.fnutils.sortByKeys(http_status_codes) do
    table.insert(choices, {
      ['code'] = k, -- gets used for the URL
      ['text'] = v, -- shown to the user
    })
  end

  chooser:choices(choices)
  chooser:show()
end

--- HttpStatus:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for HttpStatus
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * show - Show color picker menu
function obj:bindHotkeys(mapping)
   local def = {
     show = showMenu,
    }
   hs.spoons.bindHotkeysToSpec(def, mapping)
end

return obj
