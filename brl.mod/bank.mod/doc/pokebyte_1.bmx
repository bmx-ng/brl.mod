SuperStrict

Local myBank:TBank=CreateBank(16)

PokeByte myBank,0,$11
PokeShort myBank,1,$1122 ' new address = 0+1=[1]
PokeInt myBank,3,$11223344 ' new address = [1]+2=(3)
PokeLong myBank,7,$1122334455667788 ' new address = (3)+4=7
