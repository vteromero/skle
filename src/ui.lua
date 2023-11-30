function init_ui()
  tropts1=create_tropts()
  tropts2={}
  shuffle(tropts1)
  ui={
    activesection=nil,
    sections={
      transform={
        title="TRANS",
        opts={},
        selopt=1,
      },
      clear={
        title="CLEAR",
        opts={},
        selopt=1,
      },
    }
  }
  for i=1,3 do
    add(ui.sections.transform.opts,new_tropt())
  end
  for i=1,#scales do
    add(ui.sections.clear.opts,{color=scales[i].color,scale=i})
  end
  add(ui.sections.clear.opts,{label="skip",scale=0})
  scoreani=nil
  arrowsani=create_arrowsani()
end

function update_ui()
  local section=ui.activesection
  if section then
    if btnp(0) then
      section.selopt=rotil(section.selopt,#section.opts)
      sfx(0)
    elseif btnp(1) then
      section.selopt=rotir(section.selopt,#section.opts)
      sfx(0)
    end
  end
  update_score()
  update_arrows()
end

function draw_ui()
  rectfill(0,0,127,17,2)
  ?"ROUND",3,2,13
  ?tostr(round),3,10,13
  draw_section(ui.sections.transform,32,2)
  draw_section(ui.sections.clear,72,2)
  ?"SCORE",106,2,13
  draw_score()
  line(0,18,127*((round-(respawnnext-respawnfreq))/respawnfreq),18,4)
end

function set_uisection(name)
  if name then
    ui.activesection=ui.sections[name]
  else
    ui.activesection=nil
  end
end

function draw_section(section,x,y)
  local isactive=section==ui.activesection
  local col=isactive and 6 or 13
  local opt=section.opts[section.selopt]
  ?section.title,x,y,col
  if opt.label then
    ?opt.label,x+10-#opt.label*2,10,col
  else
    rectfill(x+5,10,x+13,14,opt.color)
    rect(x+5,10,x+13,14,col)
  end
  if isactive then
    draw_arrows(x,col)
    ?"❎",x+25,10,col
  end
end

function create_tropts()
  local opts={}
  for op in all(ops) do
    add(opts,{
      label=op[1]..op[2],
      op=op
    })
  end
  return opts
end

function new_tropt()
  if #tropts1==0 then
    tropts1,tropts2=tropts2,tropts1
    shuffle(tropts1)
  end
  return deli(tropts1,1)
end

function del_tropt(opts,opt)
  add(tropts2,del(opts,opt))
end

function increase_score(n,col)
  scoreani=create_ani(0,60,{
    score0=score,
    score=score,
    col=col,
    upd=function(self,t)
      self.score=flr(lerp(self.score0,score,easeoutquad(t)))
    end
  })
  score+=n
end

function update_score()
  scoreani=scoreani and update_ani(scoreani) and scoreani or nil
end

function draw_score()
  local n=scoreani and scoreani.score or score
  local col=scoreani and scoreani.col or 13
  rprint(tostr(n),124,10,col)
end

function create_arrowsani()
  return create_ani(0,60,{
    dx=0,
    upd=function(self,t)
      if t<0.5 then
        self.dx=flr(2*(t/0.5))
      elseif t>0.5 then
        self.dx=flr(2*(1-(t-0.5)/0.5))
      end
    end
  })
end

function update_arrows()
  if not update_ani(arrowsani) then
    arrowsani=create_arrowsani()
  end
end

function draw_arrows(x,col)
  ?"<",x-3-arrowsani.dx,10,col
  ?">",x+19+arrowsani.dx,10,col
end
