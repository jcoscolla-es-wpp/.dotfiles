-- Editor plugins (file explorer, fuzzy finder, etc.)
return {
  -- Color scheme: Emerald Arcana, tokyonight night remapped (scripts/palette.zsh)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night", -- night, storm, day, moon
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
        functions = {},
        variables = {},
      },
      sidebars = { "qf", "help", "neo-tree" },
      day_brightness = 0.3,
      hide_inactive_statusline = false,
      dim_inactive = false,
      lualine_bold = true,
      on_colors = function(c)
        c.bg = "#13101f"
        c.bg_dark = "#0e0b17"
        c.bg_dark1 = "#0e0b17"
        c.bg_highlight = "#1d1830"
        c.fg = "#dcd7f0"
        c.fg_dark = "#b4aed0"
        c.fg_gutter = "#3a3160"
        c.comment = "#8a82ab"
        c.dark3 = "#8a82ab"
        c.dark5 = "#8a82ab"
        c.terminal_black = "#8a82ab"
        c.blue = "#8aa0f7"
        c.blue0 = "#5b46ad"
        c.blue1 = "#52d6c8"
        c.blue2 = "#52d6c8"
        c.blue5 = "#52d6c8"
        c.blue6 = "#52d6c8"
        c.blue7 = "#3a3160"
        c.cyan = "#52d6c8"
        c.green = "#2fd49b"
        c.green1 = "#52d6c8"
        c.green2 = "#1fa87a"
        c.teal = "#2fd49b"
        c.magenta = "#d38cf5"
        c.magenta2 = "#d38cf5"
        c.purple = "#a98bf5"
        c.orange = "#f0985a"
        c.yellow = "#e8b46a"
        c.red = "#f2728c"
        c.red1 = "#d9566f"
        c.git = { add = "#1fa87a", change = "#8aa0f7", delete = "#d9566f", ignore = "#8a82ab" }

        -- tokyonight derives these before on_colors runs, so set them explicitly.
        c.black = "#0e0b17"
        c.border = "#0e0b17"
        c.border_highlight = "#a98bf5"
        c.bg_popup = "#0e0b17"
        c.bg_statusline = "#0e0b17"
        c.bg_sidebar = "#0e0b17"
        c.bg_float = "#0e0b17"
        c.fg_sidebar = "#b4aed0"
        c.fg_float = "#dcd7f0"
        c.bg_visual = "#3b2f66"
        c.bg_search = "#5b46ad"
        c.error = "#f2728c"
        c.warning = "#e8b46a"
        c.info = "#52d6c8"
        c.hint = "#2fd49b"
        c.todo = "#8aa0f7"
        -- Diff backgrounds: palette colors blended 25% (15% for change) into bg.
        c.diff = { add = "#163636", delete = "#442133", change = "#191529", text = "#3a3160" }
        c.rainbow = { "#8aa0f7", "#e8b46a", "#2fd49b", "#52d6c8", "#d38cf5", "#a98bf5", "#f0985a", "#f2728c" }
        c.terminal = {
          black = "#1d1830", black_bright = "#8a82ab",
          red = "#f2728c", red_bright = "#f2728c",
          green = "#2fd49b", green_bright = "#2fd49b",
          yellow = "#e8b46a", yellow_bright = "#e8b46a",
          blue = "#8aa0f7", blue_bright = "#8aa0f7",
          magenta = "#d38cf5", magenta_bright = "#d38cf5",
          cyan = "#52d6c8", cyan_bright = "#52d6c8",
          white = "#b4aed0", white_bright = "#dcd7f0",
        }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      { "<leader>n", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
      { "<C-n>", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        width = 35,
        mappings = {
          ["<space>"] = "none",
        },
      },
    },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in buffer" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.87,
          height = 0.80,
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Buffer line (tabs)
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        offsets = {
          { filetype = "neo-tree", text = "File Explorer", highlight = "Directory" },
        },
      },
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
      exclude = {
        filetypes = { "help", "dashboard", "neo-tree", "lazy" },
      },
    },
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Prev hunk")
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    },
  },

  -- Which-key (keybinding help)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>h", group = "git hunk" },
        { "<leader>s", group = "split" },
        { "<leader>w", desc = "Save file" },
      })
    end,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Comment
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Comment line" },
      { "gc", mode = { "n", "v" }, desc = "Comment" },
    },
    opts = {},
  },

  -- Surround
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- Tmux integration (seamless navigation between vim and tmux)
  {
    "christoomey/vim-tmux-navigator",
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right" },
    },
  },
}
