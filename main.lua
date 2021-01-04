local fuel = turtle.getFuelLevel()
local steps
local input
local scancoal = false
local arguments

local arguments1 = 1
local arguments2 = {"all",{}}
-- Ask for how many steps down
term.clear()
term.setCursorPos(1,1)
print("Your fuel level is "..fuel)
print("How many steps do you want to do?")
while true do
 term.write("turtle> ")
 steps = tonumber(read())
 if steps then
  break
 elseif steps == "cancel" or steps == "exit" then
  exit()
 else
  print("Please put in a number or write cancel to exit")
 end
end


print("put the stairs in the first slot")
print("I'll scan it and then use it regardless of the slot position")
print("press enter to continue or write cancel")
term.write("turtle> ")
input = read()
if input == "cancel" or input == "exit" then exit() end
turtle.select(1)
local item = turtle.getItemDetail()["name"]

--[[ 
you can remove the fuelrequest in every move-function 
and put it in before the digin-loop and set the minimum to 4
]]
local function fuelrequest(minimum)
 fuel = turtle.getFuelLevel()
 while true do
  if fuel < minimum then
   print("I am low on fuel and can't continue this job")
   print("Please insert "..math.ceil((steps*4-fuel)/80).." coal")
   print("press enter to continue or write skip or cancel")
   term.write("turtle> ")
   input = read()
   if input == "cancel" or input == "exit" then 
    exit() 
   elseif input == "skip" then 
    return
   end
   turtle.refuel()
   fuel = turtle.getFuelLevel()
  else
   break
  end
 end
end

local function feeditself(input) -- arg1 modes (String), arg2 number from to arg3 or every arg is a slot.
 local mode = input[1]
 local pointlist = input[2]
 if mode == "all" then
  for i=1,16,1 do
   turtle.select(i)
   turtle.refuel()
  end
 elseif mode == "area" then
  for i=pointlist[1],pointlist[2],1 do
   turtle.select(i)
   turtle.refuel()
  end
 elseif mode == "slots" then
  for _,v in pairs(pointlist) do
   turtle.select(i)
   turtle.refuel()
  end
 end
 fuelrequest(arguments1)
end


print("(1) should I ask every time for fuel or")
print("(2) should I check first the whole inventory and then ask? (2)")
while true do
 term.write("turtle> ")
 input = read()
 if input == "1" then
  scancoal = false
  feedstate = fuelrequest
  arguments = arguments1
  break
 elseif input == "2" then
  scancoal = true
  feedstate = feeditself
  arguments = arguments2
  break
 elseif input == "cancel" then
  error("Succesfully exited the program")
 else
  print("insert 1 or 2 or cancel")
 end
end


term.clear()
term.setCursorPos(1,1)
-- Check for fuel and ask for some if it is too less
local function askfuel()
 if fuel < steps*4 and scancoal == false then -- if fuel is lower than the target steps
  print("I need for this "..(steps*4).." fuel so I need more fuel...")
  print("I can calculate how much coal I would need for this job...")
  -- Calculate the needed fuel into how many coal
  local calc = (steps*4-fuel)/80
  print("("..(steps*4).."-"..fuel..")/80 = "..calc.." ~ "..math.ceil(calc).." coal so just put it in the first slot") 
  print("press enter to continue or write skip,cancel")
  term.write("turtle> ")
  input = read()
  if input == "cancel" or input == "exit" then 
   exit() 
  elseif input == "skip" then 
   return
  end
  turtle.refuel()
  fuel = turtle.getFuelLevel()
  print("Refueled. Now I have "..fuel)
  while true do -- loop again
   if (fuel <= steps*4) == false then
    print("I still need "..((steps*4-fuel)/80).." coal")
    print("press enter to continue or write skip,cancel")
    term.write("turtle> ")
    input = read()
    if input == "cancel" or input == "exit" then 
     exit() 
    elseif input == "skip" then 
     return 
    end
    turtle.refuel()
    fuel = turtle.getFuelLevel()
    print("Refueled. Now I have "..fuel)
   else
    break
   end
  end
 elseif fuel < steps*4 and scancoal == true then
  feeditself(arguments2)
 else
  print("Great I have enough fuel for this job")
 end
end

askfuel()


local function display()

 -- screen is x,y = 39,13
 fuel = turtle.getFuelLevel()
 local posx,posy = term.getCursorPos()
 local fuelstring = "  "..fuel.." Fuel Level" 
 local x = 40-string.len(fuelstring)
 term.setCursorPos(x,13)
 term.write(fuelstring)
 local stepsstring = "  "..steps.." steps left"
 local x = 40-string.len(stepsstring)
 term.setCursorPos(x,12)
 term.write(stepsstring)
 term.setCursorPos(posx,posy)
end

local function scanslot()
 return turtle.getItemDetail()["name"]
end

local function placeStairsScan()
 for i=1,16,1 do
  turtle.select(i)
  local _,scannedItem = pcall(scanslot)
  if item == scannedItem then
   turtle.place()
   return true
  end
 end
 return false
end

local function placeStairs()
 local _,scannedItem = pcall(scanslot)
 if item == scannedItem then -- if the selected slot has the stairs then just place it and continue
  turtle.place()
  return
 else -- if it hasn't then scan the whole inventory for it
  while placeStairsScan() == false do
   print("there are no stairs anymore")
   print("Can you please insert some stairs and press enter?")
   term.write("turtle> ")
   read()
  end
 end
 term.clear()
 term.setCursorPos(1,1)
end

local function forward()
 while fuel < arguments1 do feedstate(arguments) end
 display()
 while turtle.forward() == false do
  turtle.dig()
 end
end

local function down()
 while fuel < arguments1 do feedstate(arguments) end
 display()
 while turtle.down() == false do
  turtle.digDown()
 end
end

local function up()
 while fuel < arguments1 do feedstate(arguments) end
 display()
 while turtle.up() == false do
  turtle.digUp()
 end
end

local function digin()
 turtle.dig()
 turtle.digUp()
 turtle.digDown()
 up()
 turtle.dig()
 forward()
 turtle.dig()
 down()
 turtle.dig()
 turtle.digDown()
 down()
 turtle.turnRight() turtle.turnRight()
 placeStairs()
 turtle.turnRight() turtle.turnRight()
end

term.clear()
term.setCursorPos(1,1)
while steps > 0 do

digin()
steps = steps - 1

end


