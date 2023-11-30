function init_intro()
  introcardcols={7,6,5}
  intropoints={
    -- S
    {30,44},
    {27,44},
    {24,45},
    {21,46},
    {19,49},
    {20,53},
    {23,55},
    {26,57},
    {29,59},
    {31,61},
    {30,64},
    {27,66},
    {23,67},
    {19,67},
    -- K
    {45,43},
    {45,47},
    {45,50},
    {45,53},
    {45,57},
    {45,61},
    {45,66},
    {47,54},
    {50,50},
    {52,48},
    {55,46},
    {59,44},
    {50,57},
    {54,60},
    {57,62},
    {60,65},
    -- L
    {72,43},
    {72,46},
    {72,48},
    {72,51},
    {72,54},
    {72,57},
    {72,59},
    {72,63},
    {72,67},
    {74,67},
    {77,67},
    {80,67},
    {84,67},
    -- E
    {106,67},
    {103,67},
    {98,67},
    {94,67},
    {94,63},
    {93,59},
    {93,54},
    {96,54},
    {100,54},
    {92,49},
    {92,46},
    {92,42},
    {96,42},
    {100,42},
    {104,42},
  }
  introcards={}
  for pt in all(intropoints) do
    local x,y=unpack(pt)
    local n=flr(rnd(3))+1
    add(introcards,create_ani(0,0,{
      x0=x,
      y0=y,
      x=x,
      y=y,
      dx=0,
      dy=0,
      n=n,
      col=introcardcols[n],
      upd=function(self,t)
        self.x+=self.dx
        self.y+=self.dy
      end,
      drw=function(self)
        rectfill(self.x,self.y,self.x+1,self.y+1,self.col)
      end,
      onend=function(self)
        local mage=60
        local tx,ty=self.x0+rnd(2)-1,self.y0+rnd(2)-1
        self.dx=(tx-self.x)/mage
        self.dy=(ty-self.y)/mage
        self.age=0
        self.mage=mage
      end
    }))
  end
  music(0)
end

function upd_intro()
  if btnp(5) then
    set_gstate("transition")
  end
  for c in all(introcards) do
    update_ani(c)
  end
end

function drw_intro()
  cls(0)
  draw_anis(introcards)
  cprint("press ❎ to start",90,15)
  if highscore>0 then
    cprint("highscore: "..highscore,105,3)
  end
  print(version,3,120,2)
  rprint("BY vICENTE rOMERO",123,120,2)
end

function init_transition()
  numtable=create_numtable()
  trancards={}
  shuffle(introcards)
  for i=1,rows*cols do
    local introcard=introcards[i]
    local r=((i-1)\cols)+1
    local c=((i-1)%cols)+1
    local x0,y0=introcard.x,introcard.y
    local x1,y1=get_cell_pos(r,c)
    add(trancards,create_ani(0,40,{
      x0=x0,
      y0=y0,
      x1=x1,
      y1=y1,
      x=x0,
      y=y0,
      sz=2,
      col=introcard.col,
      upd=function(self,t)
        self.x=lerp(self.x0,self.x1,easeoutquad(t))
        self.y=lerp(self.y0,self.y1,easeoutquad(t))
        self.sz=lerp(2,13,t)
      end,
      drw=function(self)
        rectfill(self.x,self.y,self.x+self.sz-1,self.y+self.sz-1,self.col)
      end
    }))
    numtable[r][c]=new_num_sc(introcard.n)
  end
  music(-1,500)
end

function upd_transition()
  update_anis(trancards)
  if #trancards==0 then
    start_game(numtable)
  end
end

function drw_transition()
  cls(0)
  draw_anis(trancards)
end
