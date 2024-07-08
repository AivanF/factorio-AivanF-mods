
function table.extend(t1, t2)
  for i = 1, #t2 do
	t1[#t1 + 1] = t2[i]
  end
  return t1
end


function table.append(array, value)
	array[#array+1] = value
end


function table.keys(dict)
	local result = {}
	for k, v in pairs(dict) do
		table.append(result, k)
	end
	return result
end
