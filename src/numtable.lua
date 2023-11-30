function create_numtable()
  local tb={}
  for i=1,rows do
    local row={}
    for j=1,cols do
      add(row,new_num())
    end
    add(tb,row)
  end
  return tb
end

function new_num_sc(n)
  if n==1 then
    return 1+flr(rnd(9))
  elseif n==2 then
    return 10+flr(rnd(90))
  elseif n==3 then
    return 100+flr(rnd(900))
  else
    return 0
  end
end

function new_num()
  local r=rnd()
  if r<0.33 then
    return new_num_sc(1)
  elseif r<0.66 then
    return new_num_sc(2)
  else
    return new_num_sc(3)
  end
end

function draw_numtable()
  for i=1,rows do
    for j=1,cols do
      local x,y=get_cell_pos(i,j)
      draw_numcard(numtable[i][j],x,y)
    end
  end
end

function draw_numcard(num,x,y)
  if num==-1 then
    fillp((x+y)%2==0 and 0x5a5a or 0xa5a5)
    rect(x,y,x+cardw-1,y+cardh-1,2)
    fillp()
  elseif num==0 then
    rectfill(x,y,x+cardw-1,y+cardh-1,15)
    pal(15,0)
    spr(1,x+4,y+4)
    pal(15,15)
  elseif num>0 then
    local col=scales[get_num_scale(num)].color
    local txtcol=scales[get_num_scale(num)].textcol
    local text=tostr(num)
    local tx=x+(cardw-#text*4)\2+1
    local ty=y+(cardh-6)\2+1
    rectfill(x,y,x+cardw-1,y+cardh-1,col)
    ?text,tx,ty,txtcol
  end
end

function get_num_scale(n)
  if n<1 then
    return 0
  elseif n<10 then
    return 1
  elseif n<100 then
    return 2
  elseif n<1000 then
    return 3
  else
    return 0
  end
end

function get_cell_pos(r,c)
  return numtbx0+(c-1)*cellw,numtby0+(r-1)*cellh
end

function apply_op(op)
  for i=1,rows do
    for j=1,cols do
      if numtable[i][j]>0 then
        numtable[i][j]=run_op(numtable[i][j],op)
      end
    end
  end
end

function run_op(num,op)
  local sym,m=unpack(op)
  local new=0
  if sym=="+" then
    new=num+m
  elseif sym=="-" then
    new=num-m
  elseif sym=="X" then
    new=num*m
  elseif sym=="/" then
    new=flr(num/m)
  end
  if new<1 or new>999 then
    return 0
  else
    return new
  end
end

function count_scales()
  local tb={}
  for i=0,#scales do
    tb[i]=0
  end
  for i=1,rows do
    for j=1,cols do
      if numtable[i][j]~=-1 then
        tb[get_num_scale(numtable[i][j])]+=1
      end
    end
  end
  return tb
end

function count_remaining_cards()
  local n=0
  for i=1,rows do
    for j=1,cols do
      if numtable[i][j]~=-1 then
        n+=1
      end
    end
  end
  return n
end

function get_rndemptycards(ratio)
  local empty={}
  for i=1,rows do
    for j=1,cols do
      if numtable[i][j]==-1 or numtable[i][j]==0 then
        add(empty,{i,j})
      end
    end
  end
  shuffle(empty)
  local n=flr(#empty*ratio)
  local out={}
  for i=1,n do
    add(out,empty[i])
  end
  return out
end
