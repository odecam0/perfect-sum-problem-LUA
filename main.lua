-- This function is the input, for now it gets the queue table from a file.
function readQueue()
   require "input"
   return queue
end 


-- getTableSize is an auxiliary function for getGroupsAndSize
-- getGroupsAndSize will generate 2 tables, one with names of the groups, and
-- the other with the amount of players in that group, these information will
-- be fed to the getPerfectSum algorithm, that finds the first match of groups
-- that sum to a given value.
function getTableSize(tbl)
   local size = 0
   for _, _ in pairs(tbl) do size = size + 1 end
   return size
end
function getGroupsAndSize(tbl)
   local groups = {}
   local sizes  = {}
   for k, v in pairs(tbl) do
      table.insert(groups, k)
      table.insert(sizes,  getTableSize(v.players))
   end
   return groups, sizes
end


-- shallowCopy and arraySum are auxiliary functions to getPerfecSum
-- getPerfectSum returns the indexes and values of the first subset of
-- groups that sum the amount of players to the apropriate value
function shallowCopy(tbl)
   local copy = {}
   for k,v in pairs(tbl) do
      copy[k] = v
   end
   return copy
end
function arraySum(array)
   local sum = 0
   if not array then return 0 end
   for _,v in pairs(array) do
      sum = sum + v
   end
   return sum
end
function getPerfectSum(array, index, selected, sum)
   if index > #array then return false end

   local copy = shallowCopy(selected)  
   copy[index] = array[index]           
   local node_sum = arraySum(copy)
   if node_sum > sum then return false end

   if node_sum == sum then return copy end

   local esq = getPerfectSum(array, index+1, copy, sum)
   if not esq then return getPerfectSum(array, index+1, selected, sum) end
   return esq
   end


-- Given the indexes returned by getPerfectSum, getGroupsFromIndexes
-- will return the associated group names from those indexes.
function getGroupsFromIndexes(indexes, groups)
   local selected_groups = {}
   for k, _ in pairs(indexes) do
      table.insert(selected_groups, groups[k])
   end
   return selected_groups
end


function assignGroupsToTeam(teams, groups, queue)
   local team_name, team_players
   if teams.blue then team_name = "red" else team_name = "blue" end

   teams[team_name] = {players={}}
   for _, vg in pairs(groups) do
      for _, vp in pairs(queue[vg].players) do
	 team_players = teams[team_name].players
	 table.insert(team_players, vp)
	 team_players[#team_players].group = vg
      end
   end

   return teams
end

function removeGroupsFromQueue(groups, queue)
   local new_queue = shallowCopy(queue)
   for k,v in pairs(groups) do
      new_queue[v] = nil
   end
   return new_queue
end


-- getTeamMatch gets a queue as parameter and returns the red and blue
-- teams. It also returns a queue without the groups that were added to the
-- teams.
function getTeamMatch(queue)
   -- getting blue team
   local groups, sizes = getGroupsAndSize(queue)
   local indexes_to_remove = getPerfectSum(sizes, 1, {}, 5)
   local groups_to_remove = getGroupsFromIndexes(indexes_to_remove, groups)
   local teams = assignGroupsToTeam({}, groups_to_remove, queue)
   local new_queue = removeGroupsFromQueue(groups_to_remove, queue)

   -- getting red team
   groups, sizes = getGroupsAndSize(new_queue)
   indexes_to_remove = getPerfectSum(sizes, 1, {}, 5)
   groups_to_remove = getGroupsFromIndexes(indexes_to_remove, groups)
   teams = assignGroupsToTeam(teams, groups_to_remove, new_queue)
   new_queue = removeGroupsFromQueue(groups_to_remove, new_queue)
   return teams, new_queue
end

--[[
getTeamMatch(readQueue())
--]]
