table.insert(package.searchers, 2, function(modulename)
    local errmsg = "";
    local filename = modulename .. ".lua";
    if DoesFileExist(filename) then
        return assert(load(assert(LoadFile(filename))));
    else
        errmsg = errmsg.."\n\tno asset '"..filename .. "'";
    end
    return errmsg;
end);

require("Mission8");