Developer Workflow

- Use Ctrl+Shift+L in Wireshark to reload Lua plugins.
- For targeted reloads, use a small loader script that calls dofile() after removing existing registrations.
- Remove and re-add dissectors via DissectorTable:remove() and DissectorTable:add().
- Use package.prepend_path to include the modules directory for shared code.

Example Reload Snippet

package.prepend_path(".")
local t = DissectorTable.get("tcp.port")
t:remove(0)
dofile("path/to/your_dissector.lua")
