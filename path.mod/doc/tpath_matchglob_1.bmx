SuperStrict

Framework brl.standardio
Import BRL.Path

Local a:TPath = New TPath("/tmp/ReadMe.TXT")
Local b:TPath = New TPath("/tmp/.hidden")

' Case sensitive by default
Print a.MatchGlob("readme.txt") ' False

' CaseFold enables case-insensitive matching
Print a.MatchGlob("readme.txt", EGlobOptions.CaseFold) ' True

' Dotfiles are not matched by wildcard patterns by default
Print b.MatchGlob(".*") ' False

' Period allows wildcard patterns to match leading '.'
Print b.MatchGlob(".*", EGlobOptions.Period) ' True
