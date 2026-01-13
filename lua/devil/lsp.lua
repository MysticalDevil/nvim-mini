local servers = {
  -- Lua (lua_ls)
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        hint = {
          enable = true,
          arrayIndex = "Auto",
          await = true,
          paramName = "All",
          paramType = true,
          semicolon = "SameLine",
          setType = false,
        },
        completion = { callSnippet = "Replace" },
      },
    },
    single_file_support = true,
  },

  -- Zig (zls)
  zls = {
    settings = {
      zls = {
        enable_snippets = true,
        enable_argument_placeholders = true,
        enable_ast_check_diagnostics = true,
        enable_build_on_save = true,
        enable_autofix = false,
        semantic_tokens = "full",
        enable_inlay_hints = true,
        inlay_hints_show_variable_type_hints = true,
        inlay_hints_show_parameter_name = true,
        inlay_hints_show_builtin = true,
        inlay_hints_exclude_single_argument = true,
        warn_style = false,
        highlight_global_var_declarations = false,
        completions_with_replace = true,
      },
    },
    single_file_support = true,
  },

  -- Go (gopls)
  gopls = {
    settings = {
      gopls = {
        experimentalPostfixCompletions = true,
        analyses = {
          shadow = true,
          fieldalignment = true,
          nilness = true,
          unusedparams = true,
          unusedwrite = true,
          useany = true,
        },
        gofumpt = true,
        hints = {
          rangeVariableTypes = true,
          parameterNames = true,
          constantValues = true,
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          functionTypeParameters = true,
        },
        codelenses = {
          gc_details = false,
          generate = true,
          regenerate_cgo = true,
          run_govulncheck = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          vendor = true,
        },
        usePlaceholders = true,
        completeUnimported = true,
        staticcheck = true,
        directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
        semanticTokens = true,
      },
    },
    init_options = {
      usePlaceholders = true,
    },
    single_file_support = true,
  },

  -- Rust (rust_analyzer)
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        inlayHints = {
          chainingHints = { enable = true },
          closingBraceHints = { enable = true, minLines = 25 },
          parameterHints = { enable = true },
          typeHints = { enable = true },
        },
        checkOnSave = {
          allFeatures = true,
          overrideCommand = {
            "cargo",
            "clippy",
            "--workspace",
            "--message-format=json",
            "--all-targets",
            "--all-features",
          },
        },
        cargo = {
          autoReload = true,
          loadOutDirsFromCheck = true,
        },
        procMacro = { enable = true },
        diagnostics = { enable = true },
      },
    },
  },
}

for server, config in pairs(servers) do
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

local km = require("devil.keymap")
local utils = require("devil.utils")
local cmp = require("devil.cmp")

vim.opt.completeopt = { "menuone", "noselect", "popup" }

utils.set_keymaps(cmp.mappings)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    vim.lsp.completion.enable(true, client.id, bufnr, {
      autotrigger = true,
    })

    utils.apply(km.lsp, { buffer = bufnr })
  end,
})
