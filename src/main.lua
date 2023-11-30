function _init()
  version="V1.0"
  cartdata("vteromero_skle_1_0")
  highscore=dget(0)
  ops={
    {"+",10},{"+",50},{"+",100},{"+",500},
    {"-",1},{"-",10},{"-",50},
    {"X",2},{"X",5},{"X",10},{"X",20},
    {"/",2},{"/",5},{"/",10},{"/",100},
  }
  scales={
    {color=10,textcol=0,points=4},
    {color=12,textcol=0,points=3},
    {color=8,textcol=6,points=2},
  }
  numtbx0=5
  numtby0=21
  rows=7
  cols=8
  cardw=13
  cardh=13
  cellw=cardw+2
  cellh=cardh+2
  gstates={
    intro={init_intro,upd_intro,drw_intro},
    transition={init_transition,upd_transition,drw_transition},
    transform={init_transform,upd_transform,drw_transform},
    clear={init_clear,upd_clear,drw_clear},
    round_end={init_roundend,upd_roundend,drw_roundend},
    game_end0={init_gameend0,upd_gameend0,drw_gameend0},
    game_end1={init_gameend1,upd_gameend1,drw_gameend1},
  }
  mincards=5
  set_colorpal()
  set_gstate("intro")
end

function start_game(ntable)
  round=1
  score=0
  respawnfreq=10
  respawnnext=10
  respawnratio=0.5
  numtable=ntable or create_numtable()
  init_ui()
  set_gstate("transform")
  music(5)
end

function _update60()
  _upd()
end

function _draw()
  _drw()
end

function set_gstate(st)
  local init,drw,upd=unpack(gstates[st])
  init()
  _upd=upd
  _drw=drw
end

function init_transform()
  set_uisection("transform")
end

function upd_transform()
  update_ui()
  if btnp(5) then
    local section=ui.activesection
    apply_op(section.opts[section.selopt].op)
    sfx(1)
    set_gstate("clear")
  end
end

function drw_transform()
  cls(0)
  draw_numtable()
  draw_ui()
end

function init_clear()
  set_uisection("clear")
end

function upd_clear()
  update_ui()
  if btnp(5) then
    sfx(1)
    set_gstate("round_end")
  end
end

function drw_clear()
  cls(0)
  draw_numtable()
  draw_ui()
end

function init_roundend()
  roundendanis={}
  roundscore=0
  local freqs=count_scales()
  local totalcards=count_remaining_cards()
  local sc=ui.sections.clear.opts[ui.sections.clear.selopt].scale
  -- calculate round score
  if sc>0 then
    local mult=1
    if freqs[sc]==totalcards then
      mult=3
    elseif freqs[sc]+freqs[0]==totalcards then
      mult=2
    end
    roundscore=freqs[sc]*scales[sc].points*mult
    if roundscore>0 then
      local breakdownbase=freqs[sc].."X"..scales[sc].points
      local breakdown=mult>1 and breakdownbase.."X"..mult or breakdownbase
      local breakdowncol=mult==1 and 6 or (mult==2 and 9 or 14)
      local inc="+"..roundscore
      increase_score(roundscore,scales[sc].color)
      add(roundendanis,new_pointsani(26,0,40,breakdown,breakdowncol))
      add(roundendanis,new_pointsani(26,25,40,inc,7))
      sfx(2)
    end
  end
  -- re-spawn cards
  if respawnnext==round then
    local cards=get_rndemptycards(respawnratio)
    for c in all(cards) do
      local r,c=unpack(c)
      local num=new_num()
      add(roundendanis,new_spawnani(r,c,scales[get_num_scale(num)].color,num,50+flr(rnd(20))))
    end
    add(roundendanis,new_respawnlineani(60))
  end
  -- remove out-of-scale cards
  for i=1,rows do
    for j=1,cols do
      if numtable[i][j]==0 then
        add(roundendanis,new_outofscaleani(i,j))
        numtable[i][j]=-2
      end
    end
  end
  -- clear cards
  for i=1,rows do
    for j=1,cols do
      local n=numtable[i][j]
      if n>0 and get_num_scale(n)==sc then
        local num=new_num()
        add(roundendanis,new_clearani(i,j,scales[sc].color))
        add(roundendanis,new_spawnani(i,j,scales[get_num_scale(num)].color,num,10+flr(rnd(20))))
        numtable[i][j]=-2
      end
    end
  end
  sort_anis(roundendanis)
  set_uisection(nil)
end

function upd_roundend()
  update_ui()
  update_anis(roundendanis)
  if #roundendanis==0 then
    if count_remaining_cards()<mincards then
      set_gstate("game_end0")
    else
      local section=ui.sections.transform
      local opt=section.opts[section.selopt]
      del_tropt(section.opts,opt)
      add(section.opts,new_tropt())
      if respawnnext==round then
        respawnnext+=respawnfreq
        respawnfreq+=1
      end
      round+=1
      set_gstate("transform")
    end
  end
end

function drw_roundend()
  cls(0)
  draw_numtable()
  draw_ui()
  draw_anis(roundendanis)
end

function new_outofscaleani(r,c)
  local x0,y0=get_cell_pos(r,c)
  return create_ani(flr(rnd(20)),25,{
    r=r,
    c=c,
    x0=x0,
    y0=y0,
    x=x0,
    y=y0,
    w=cardw,
    h=cardh,
    z=1,
    upd=function(self,t)
      local invt=1-t
      self.w=cardw*invt
      self.h=cardh*invt
      self.x=self.x0+(cardw-self.w)\2
      self.y=self.y0+(cardh-self.h)\2
    end,
    drw=function(self)
      rectfill(self.x,self.y,self.x+self.w-1,self.y+self.h-1,2)
    end,
    onend=function(self)
      numtable[self.r][self.c]=-1
    end
  })
end

function new_clearani(r,c,col)
  local x0,y0=get_cell_pos(r,c)
  return create_ani(flr(rnd(20)),25,{
    x0=x0,
    y0=y0,
    x=x0,
    y=y0,
    w=cardw,
    h=cardh,
    col=col,
    z=2,
    upd=function(self,t)
      local invt=1-t
      self.x=lerp(self.x0,124,t)
      self.y=lerp(self.y0,14,t)
      self.w=cardw*invt
      self.h=cardh*invt
    end,
    drw=function(self)
      rectfill(self.x,self.y,self.x+self.w-1,self.y+self.h-1,self.col)
    end
  })
end

function new_spawnani(r,c,col,num,wait)
  local x0,y0=get_cell_pos(r,c)
  return create_ani(wait,25,{
    r=r,
    c=c,
    num=num,
    x0=x0,
    y0=y0,
    x=x0,
    y=y0,
    w=0,
    h=0,
    col=col,
    z=1,
    upd=function(self,t)
      self.w=cardw*t
      self.h=cardh*t
      self.x=self.x0+(cardw-self.w)\2
      self.y=self.y0+(cardh-self.h)\2
    end,
    drw=function(self)
      if self.w>0 and self.h>0 then
        rectfill(self.x,self.y,self.x+self.w-1,self.y+self.h-1,self.col)
      end
    end,
    onend=function(self)
      numtable[self.r][self.c]=self.num
    end
  })
end

function new_respawnlineani(wait)
  return create_ani(wait,30,{
    col=4,
    z=1,
    upd=function(self,t)
      self.col=(t*30\1)%8==0 and 4 or 7
    end,
    drw=function(self)
      line(0,18,127,18,self.col)
    end
  })
end

function new_pointsani(y,wait,mage,s,col)
  local x=126-#s*4
  return create_ani(wait,mage,{
    x=x,
    y=y,
    s=s,
    col=col,
    z=3,
    upd=function(self,t)
      self.y-=0.25
    end,
    drw=function(self)
      if self.wait<=0 then
        outlined(self.s,self.x,self.y,0,self.col)
      end
    end
  })
end

function init_gameend0()
  stripsani=create_ani(0,45,{
    gap=6,
    h=0,
    upd=function(self,t)
      self.h=flr(self.gap*easeoutquad(t))+1
    end,
    drw=function(self)
      clip(0,goy0,128,goy1-goy0+1)
      for y=0,127,self.gap do
        local y0=y-self.h\2
        local y1=y0+self.h-1
        rectfill(0,y0,127,y1,1)
        for i=y0,y1 do
          tline(gotitlex,i,gotitlex+80,i,0,(i-gotitley)*0.125)
        end
      end
      clip()
    end
  })
  goy0=29
  goy1=98
  gotitlex=26
  gotitley=40
  if score>highscore then
    highscore=score
    dset(0,highscore)
  end
  music(-1)
  sfx(3)
end

function upd_gameend0()
  update_ui()
  if not update_ani(stripsani) then
    set_gstate("game_end1")
  end
end

function drw_gameend0()
  cls(0)
  draw_numtable()
  draw_ui()
  stripsani:drw()
end

function init_gameend1()
  music(0,8000)
end

function upd_gameend1()
  update_ui()
  if btnp(5) then
    start_game()
  end
end

function drw_gameend1()
  cls(0)
  draw_numtable()
  draw_ui()
  rectfill(0,goy0,127,goy1,1)
  line(0,goy0,127,goy0,6)
  line(0,goy1,127,goy1,6)
  map(0,0,gotitlex,gotitley)
  cprint("SCORE: "..score,60,10)
  cprint("HIGHSCORE: "..highscore,69,12)
  cprint("TRY AGAIN?",83,13)
  if ((t()*60)\40)%2==0 then
    ?"❎",90,83,13
  end
end

function set_colorpal()
  local colors=split"1,130,131,4,5,6,7,136,9,135,11,12,13,14,141"
  colors[0]=128
  pal(colors,1)
end

function rotir(i,n)
  return (i%n)+1
end

function rotil(i,n)
  return ((i-2)%n)+1
end

function lerp(a,b,t)
  return a+(b-a)*t
end

-- fisher-yates
function shuffle(t)
  for i=#t,1,-1 do
    local j=flr(rnd(i))+1
    t[i],t[j]=t[j],t[i]
  end
  return t
end

-- simple insertion sort
function sort(a,cmp)
  for i=1,#a do
    local j=i
    while j>1 and cmp(a[j-1],a[j]) do
      a[j],a[j-1]=a[j-1],a[j]
      j=j-1
    end
  end
end

function easeinquad(t)
  return t*t
end

function easeoutquad(t)
  t-=1
  return 1-t*t
end

-- right-aligned print. (x,y) is the top-right corner
function rprint(s,x,y,col)
  print(s,x-#s*4+2,y,col)
end

-- horizontally-centered print
function cprint(s,y,col)
  print(s,65-#s*2,y,col)
end

-- print outlined text. c0: bg color; c1: text color
function outlined(text,x,y,c0,c1)
  for i=0,2 do
    for j=0,2 do
      print(text,x+i,y+j,c0)
    end
  end
  print(text,x+1,y+1,c1)
end
