[
  import_deps: [:ecto, :ecto_sql, :phoenix, :surface],
  subdirectories: ["priv/*/migrations"],
  plugins: [Surface.Formatter.Plugin],
  inputs: [
    "*.{heex, sface,ex,exs}",
    "{config,lib,test}/**/*.{heex, sface, ex,exs}",
    "*.{ex,exs}",
    "{config,lib,test}/**/*.{ex,exs}",
    "priv/*/seeds.exs"
  ]
]
