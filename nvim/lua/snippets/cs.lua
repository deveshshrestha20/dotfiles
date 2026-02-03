local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

-- Helper function to get namespace from file path
local function get_namespace()
  local filepath = vim.fn.expand("%:p")
  local filename = vim.fn.expand("%:t:r")

  -- Find common C# project root indicators
  local project_roots = {
    "%.csproj$",
    "%.sln$",
    "src/",
    "Program%.cs$",
  }

  -- Try to find project root
  local path_parts = vim.split(filepath, "/")
  local namespace_parts = {}
  local in_namespace = false

  for i, part in ipairs(path_parts) do
    -- Start collecting after we find src, or a .csproj file
    if part == "src" or part:match("%.csproj$") then
      in_namespace = true
    elseif in_namespace and part ~= filename .. ".cs" then
      -- Skip common folder names that shouldn't be in namespace
      if part ~= "bin" and part ~= "obj" and part ~= "Properties" then
        table.insert(namespace_parts, part)
      end
    end
  end

  -- If we didn't find a proper structure, try alternative approach
  if #namespace_parts == 0 then
    -- Look for the parent directory name as project name
    for i = #path_parts - 1, 1, -1 do
      if path_parts[i]:match("%.csproj$") or path_parts[i] == "src" or (i > 1 and not path_parts[i]:match("^%.")) then
        table.insert(namespace_parts, 1, path_parts[i])
        break
      end
    end
  end

  -- Convert to PascalCase and join with dots
  local namespace = table.concat(namespace_parts, ".")

  -- If still empty, use the parent directory
  if namespace == "" then
    namespace = path_parts[#path_parts - 1] or "MyNamespace"
  end

  return namespace
end

-- Must return a table of snippets
return {
  -- Smart namespace snippet (file-scoped with semicolon)
  s("namespace", {
    t("namespace "),
    f(function()
      return get_namespace()
    end),
    t(";"),
  }),

  -- Namespace with braces (old style) - if you ever need it
  s(
    "namespaceb",
    fmt(
      [[
    namespace {}
    {{
        {}
    }}
  ]],
      {
        f(function()
          return get_namespace()
        end),
        i(0),
      }
    )
  ),
  -- Class snippet
  s(
    "class",
    fmt(
      [[
    public class {}
    {{
        {}
    }}
  ]],
      {
        f(function()
          return vim.fn.expand("%:t:r")
        end),
        i(0),
      }
    )
  ),

  -- Complete class with namespace and constructor (SMART)
  s("classn", {
    t("namespace "),
    f(function()
      return get_namespace()
    end),
    t(";"),
    t({ "", "", "public class " }),
    f(function()
      return vim.fn.expand("%:t:r")
    end),
    t({ "", "{", "    public " }),
    f(function()
      return vim.fn.expand("%:t:r")
    end),
    t("("),
    i(1),
    t(")"),
    t({ "", "    {", "        " }),
    i(2),
    t({ "", "    }", "", "    " }),
    i(0),
    t({ "", "}" }),
  }),

  -- Complete interface with namespace (SMART)
  s("interfacen", {
    t("namespace "),
    f(function()
      return get_namespace()
    end),
    t(";"),
    t({ "", "", "public interface " }),
    f(function()
      local filename = vim.fn.expand("%:t:r")
      -- If filename doesn't start with I, add it
      if not filename:match("^I") then
        return "I" .. filename
      end
      return filename
    end),
    t({ "", "{", "    " }),
    i(0),
    t({ "", "}" }),
  }),

  -- Complete record with namespace (SMART)
  s("recordn", {
    t("namespace "),
    f(function()
      return get_namespace()
    end),
    t(";"),
    t({ "", "", "public record " }),
    f(function()
      return vim.fn.expand("%:t:r")
    end),
    t("("),
    i(1, "string Name"),
    t(");"),
    t({ "", "" }),
    i(0),
  }),

  -- Complete enum with namespace (SMART)
  s("enumn", {
    t("namespace "),
    f(function()
      return get_namespace()
    end),
    t(";"),
    t({ "", "", "public enum " }),
    f(function()
      return vim.fn.expand("%:t:r")
    end),
    t({ "", "{", "    " }),
    i(1, "Value1"),
    t(","),
    t({ "", "    " }),
    i(2, "Value2"),
    t({ "", "}" }),
  }),

  -- Controller class with namespace (SMART for ASP.NET)
  s("controllern", {
    t("namespace "),
    f(function()
      return get_namespace()
    end),
    t(";"),
    t({ "", "", "using Microsoft.AspNetCore.Mvc;", "", "[ApiController]" }),
    t({ "", '[Route("api/[controller]")]' }),
    t({ "", "public class " }),
    f(function()
      return vim.fn.expand("%:t:r")
    end),
    t(" : ControllerBase"),
    t({ "", "{", "    private readonly " }),
    i(1, "ILogger"),
    t(" _logger;"),
    t({ "", "", "    public " }),
    f(function()
      return vim.fn.expand("%:t:r")
    end),
    t("("),
    f(function(args)
      return args[1][1]
    end, { 1 }),
    t(" logger)"),
    t({ "", "    {", "        _logger = logger;", "    }" }),
    t({ "", "", "    " }),
    i(0),
    t({ "", "}" }),
  }),

  -- Service class with namespace and constructor injection (SMART)
  s("servicen", {
    t("namespace "),
    f(function()
      return get_namespace()
    end),
    t(";"),
    t({ "", "", "public class " }),
    f(function()
      return vim.fn.expand("%:t:r")
    end),
    t({ "", "{", "    private readonly " }),
    i(1, "IRepository"),
    t(" _"),
    f(function(args)
      local dep = args[1][1]
      -- Convert IRepository to repository (lowercase first letter, remove I)
      if dep:match("^I") then
        dep = dep:sub(2)
      end
      return dep:sub(1, 1):lower() .. dep:sub(2)
    end, { 1 }),
    t(";"),
    t({ "", "", "    public " }),
    f(function()
      return vim.fn.expand("%:t:r")
    end),
    t("("),
    f(function(args)
      return args[1][1]
    end, { 1 }),
    t(" "),
    f(function(args)
      local dep = args[1][1]
      if dep:match("^I") then
        dep = dep:sub(2)
      end
      return dep:sub(1, 1):lower() .. dep:sub(2)
    end, { 1 }),
    t(")"),
    t({ "", "    {", "        _" }),
    f(function(args)
      local dep = args[1][1]
      if dep:match("^I") then
        dep = dep:sub(2)
      end
      return dep:sub(1, 1):lower() .. dep:sub(2)
    end, { 1 }),
    t(" = "),
    f(function(args)
      local dep = args[1][1]
      if dep:match("^I") then
        dep = dep:sub(2)
      end
      return dep:sub(1, 1):lower() .. dep:sub(2)
    end, { 1 }),
    t(";"),
    t({ "", "    }", "", "    " }),
    i(0),
    t({ "", "}" }),
  }),

  -- POCO/Model class with namespace (SMART)
  s("modeln", {
    t("namespace "),
    f(function()
      return get_namespace()
    end),
    t(";"),
    t({ "", "", "public class " }),
    f(function()
      return vim.fn.expand("%:t:r")
    end),
    t({ "", "{", "    public int Id { get; set; }", "", "    public string " }),
    i(1, "Name"),
    t(" { get; set; }"),
    t({ "", "", "    " }),
    i(0),
    t({ "", "}" }),
  }),

  -- Test class with namespace (SMART for xUnit/NUnit)
  s("testn", {
    t("namespace "),
    f(function()
      return get_namespace()
    end),
    t(";"),
    t({ "", "", "using Xunit;", "", "public class " }),
    f(function()
      return vim.fn.expand("%:t:r")
    end),
    t({ "", "{", "    [Fact]", "    public void " }),
    i(1, "Test_Method_Should_Work"),
    t("()"),
    t({ "", "    {", "        // Arrange", "        " }),
    i(2),
    t({ "", "", "        // Act", "        " }),
    i(3),
    t({ "", "", "        // Assert", "        " }),
    i(0),
    t({ "", "    }", "}" }),
  }),

  -- Interface snippet
  s(
    "interface",
    fmt(
      [[
    public interface {}
    {{
        {}
    }}
  ]],
      {
        i(1, "IInterfaceName"),
        i(0),
      }
    )
  ),

  -- Property with auto-accessors
  s(
    "prop",
    fmt(
      [[
    public {} {} {{ get; set; }}
  ]],
      {
        i(1, "string"),
        i(2, "PropertyName"),
      }
    )
  ),

  -- Read-only property
  s(
    "propro",
    fmt(
      [[
    public {} {} {{ get; }}
  ]],
      {
        i(1, "string"),
        i(2, "PropertyName"),
      }
    )
  ),

  -- Full property with backing field
  s(
    "propfull",
    fmt(
      [[
    private {} _{};
    public {} {}
    {{
        get {{ return _{}; }}
        set {{ _{} = value; }}
    }}
  ]],
      {
        i(1, "string"),
        i(2, "propertyName"),
        f(function(args)
          return args[1][1]
        end, { 1 }),
        f(function(args)
          return args[1][1]:sub(1, 1):upper() .. args[1][1]:sub(2)
        end, { 2 }),
        i(0),
        f(function(args)
          return args[1][1]
        end, { 2 }),
      }
    )
  ),

  -- Method snippet
  s(
    "method",
    fmt(
      [[
    public {} {}({})
    {{
        {}
    }}
  ]],
      {
        i(1, "void"),
        i(2, "MethodName"),
        i(3, ""),
        i(0),
      }
    )
  ),

  -- Async method
  s(
    "async",
    fmt(
      [[
    public async Task{} {}({})
    {{
        {}
    }}
  ]],
      {
        c(1, {
          t(""),
          t("<T>"),
        }),
        i(2, "MethodName"),
        i(3, ""),
        i(0),
      }
    )
  ),

  -- Constructor
  s(
    "ctor",
    fmt(
      [[
    public {}({})
    {{
        {}
    }}
  ]],
      {
        f(function()
          return vim.fn.expand("%:t:r")
        end),
        i(1, ""),
        i(0),
      }
    )
  ),

  -- For loop
  s(
    "for",
    fmt(
      [[
    for (int {} = 0; {} < {}; {}++)
    {{
        {}
    }}
  ]],
      {
        i(1, "i"),
        f(function(args)
          return args[1][1]
        end, { 1 }),
        i(2, "length"),
        f(function(args)
          return args[1][1]
        end, { 1 }),
        i(0),
      }
    )
  ),

  -- Foreach loop
  s(
    "foreach",
    fmt(
      [[
    foreach ({} {} in {})
    {{
        {}
    }}
  ]],
      {
        i(1, "var"),
        i(2, "item"),
        i(3, "collection"),
        i(0),
      }
    )
  ),

  -- Try-catch
  s(
    "try",
    fmt(
      [[
    try
    {{
        {}
    }}
    catch ({})
    {{
        {}
    }}
  ]],
      {
        i(1),
        i(2, "Exception ex"),
        i(0),
      }
    )
  ),

  -- If statement
  s(
    "if",
    fmt(
      [[
    if ({})
    {{
        {}
    }}
  ]],
      {
        i(1, "condition"),
        i(0),
      }
    )
  ),

  -- If-else statement
  s(
    "ife",
    fmt(
      [[
    if ({})
    {{
        {}
    }}
    else
    {{
        {}
    }}
  ]],
      {
        i(1, "condition"),
        i(2),
        i(0),
      }
    )
  ),

  -- Switch statement
  s(
    "switch",
    fmt(
      [[
    switch ({})
    {{
        case {}:
            {}
            break;
        default:
            {}
            break;
    }}
  ]],
      {
        i(1, "variable"),
        i(2, "value"),
        i(3),
        i(0),
      }
    )
  ),

  -- LINQ query
  s(
    "linq",
    fmt(
      [[
    var {} = from {} in {}
             where {}
             select {};
  ]],
      {
        i(1, "result"),
        i(2, "item"),
        i(3, "collection"),
        i(4, "condition"),
        i(0, "item"),
      }
    )
  ),

  -- Region
  s(
    "region",
    fmt(
      [[
    #region {}
    {}
    #endregion
  ]],
      {
        i(1, "RegionName"),
        i(0),
      }
    )
  ),

  -- Attribute
  s(
    "attr",
    fmt(
      [[
    [{}({})]
  ]],
      {
        i(1, "AttributeName"),
        i(0),
      }
    )
  ),

  -- Nullable property
  s(
    "propn",
    fmt(
      [[
    public {}? {} {{ get; set; }}
  ]],
      {
        i(1, "string"),
        i(2, "PropertyName"),
      }
    )
  ),

  -- Record
  s(
    "record",
    fmt(
      [[
    public record {}({});
  ]],
      {
        i(1, "RecordName"),
        i(0, "string Property"),
      }
    )
  ),

  -- Primary constructor (C# 12)
  s(
    "primary",
    fmt(
      [[
    public class {}({})
    {{
        {}
    }}
  ]],
      {
        i(1, "ClassName"),
        i(2, "string parameter"),
        i(0),
      }
    )
  ),

  -- Using statement
  s(
    "using",
    fmt(
      [[
    using ({} {} = {})
    {{
        {}
    }}
  ]],
      {
        i(1, "var"),
        i(2, "resource"),
        i(3, "new Resource()"),
        i(0),
      }
    )
  ),

  -- Lambda expression
  s(
    "lambda",
    fmt(
      [[
    ({}) => {}
  ]],
      {
        i(1, "x"),
        i(0, "x"),
      }
    )
  ),

  -- Test method (NUnit/xUnit style)
  s(
    "test",
    fmt(
      [[
    [Test]
    public void {}()
    {{
        // Arrange
        {}

        // Act
        {}

        // Assert
        {}
    }}
  ]],
      {
        i(1, "TestMethodName"),
        i(2),
        i(3),
        i(0),
      }
    )
  ),
}
