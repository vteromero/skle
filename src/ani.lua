function create_ani(wait,mage,data)
  local tb={}
  for k,v in pairs(data) do
    tb[k]=v
  end
  tb.wait=wait
  tb.mage=mage
  tb.age=0
  return tb
end

function update_ani(a)
  if a.wait>0 then
    a.wait-=1
  else
    a.age+=1
    if a.age>a.mage then
      if a.onend then
        a:onend()
      end
      return false
    else
      local t=a.age/a.mage
      a:upd(t)
    end
  end
  return true
end

function update_anis(anis)
  for ani in all(anis) do
    if not update_ani(ani) then
      del(anis,ani)
    end
  end
end

function draw_anis(anis)
  for ani in all(anis) do
    ani:drw()
  end
end

function sort_anis(anis)
  sort(anis,function(a,b) return a.z>b.z end)
end
