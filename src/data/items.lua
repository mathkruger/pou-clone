-- data/items.lua
local items = {
  { id="fish_small", type="food", displayName="Peixe Pequeno", price=10, hungerRestore=25, cleanlinessPenalty=5 },
  { id="fish_big", type="food", displayName="Peixe Grande", price=25, hungerRestore=60, cleanlinessPenalty=10 },
  { id="soap", type="hygiene", displayName="Sabonete", price=20, cleanRestore=50 },
  { id="shampoo", type="hygiene", displayName="Shampoo", price=40, cleanRestore=80 },
  { id="scarf_red", type="cosmetic", displayName="Lenço Vermelho", price=120, cosmetic="scarf", slot="neck", position={x=12, y=30} },
  { id="glasses_black", type="cosmetic", displayName="Óculos Escuros", price=180, cosmetic="glasses", slot="face", position={x=12, y=10} },
  { id="hat_blue", type="cosmetic", displayName="Chapéu Azul", price=150, cosmetic="hat", slot="head", position={x=11, y=-9} },
  { id="hat_red", type="cosmetic", displayName="Chapéu Vermelho", price=100, cosmetic="hat", slot="head", position={x=11, y=-9} },
  { id="suit_blue", type="cosmetic", displayName="Terno Azul", price=200, cosmetic="suit", slot="body", position={x=12, y=35} }
}
return items

