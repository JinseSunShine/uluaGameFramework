blocks = class("blocks");

function blocks:init(w, h, blockTypes)
	self.w = w;
	self.h = h;
	self.blockTyps = blockTypes;
	
	self.data = {};
	
	-- i �� �У�j �� ��
	for i=1, h do
		
		for j=1, w do
					
			self.data[j] = self.data[j] or {};
			
			self.data[j][i] = self.data[j][i] or 0;
			
		end
	
	end
	
end

function blocks:getWidth()
	return self.w;
end

function blocks:getHeight()
	return self.h;
end

function blocks:getBlockTypes()
	return self.blockTyps;
end

function blocks:getdata()
	return self.data;
end

function blocks:generate()
	
	function isTypeExist(typeValue, list)
		for k, v in pairs(list) do
			if v == typeValue then
				return true;
			end
		end
		
		return false;
	end
	
	math.randomseed(os.time());
	
	local debuginfo = "\n";
	
	for i=1, self.h do
		
		for j=1, self.w do
			
			local exceptTypes = {};
			
			if j > 2 and self.data[j-1][i] == self.data[j-2][i] then
				-- �ȽϺ��ŵ�ǰ����û����ͬ��
				table.insert(exceptTypes, self.data[j-1][i]);
			end
			
			if i > 2 and self.data[j][i-1]== self.data[j][i-2] then
				table.insert(exceptTypes, self.data[j][i-1]);
			end
			
			local validTypes = {};
			for i=1, self.blockTyps do
			
				if not isTypeExist(i, exceptTypes) then
						table.insert(validTypes, i);
				end
				
			end
			
			local randomCount = #validTypes;
			
			if randomCount == 0 then
				return false;
			end
			
			local randomKey = math.random(1, randomCount);
			self.data[j][i] = validTypes[randomKey];
			
			debuginfo = debuginfo..self.data[j][i].." ";
		end
		
		debuginfo = debuginfo.."\n";
		
	end
	
	--print(debuginfo);
	
end

function blocks:swap(x1, y1, x2, y2)
	
	if self.data[x1][y1] and self.data[x2][y2] then
	
		self.data[x1][y1], self.data[x2][y2] = self.data[x2][y2], self.data[x1][y1];
	
	end
	
end

-- ������ߣ�3�� 4 ��5����
function blocks:checkThree()
	
	print("------------checkThree--------");
	-- eraseBlocks �� local k = (i-1) * self.w + j;
	
	local eraseBlocks = {};
	
	local hasErase = false;
	
	for i=1, self.h do
		
		for j=1, self.w do
			
			local k = self:getIndexByPos(j, i);
			local currentBlock = self.data[j][i];
			
			eraseBlocks[k] = {row = false, col = false};
			
			-- check row
			if j > 2 and self.data[j-1][i] == self.data[j-2][i] and self.data[j-1][i] == currentBlock then 
				eraseBlocks[k] = { row = true, col = eraseBlocks[k].col };
				eraseBlocks[k-1] = { row = true, col = eraseBlocks[k-1].col };
				eraseBlocks[k-2] = { row = true, col = eraseBlocks[k-2].col };
				--print("row "..j.." "..i.." k "..k);
				
				hasErase = true;
			end
			
			-- check column
			if i > 2 and self.data[j][i-1] == self.data[j][i-2] and self.data[j][i-1] == currentBlock then
				eraseBlocks[k] = { row = eraseBlocks[k].row, col = true };
				eraseBlocks[k-self.w] = { row = eraseBlocks[k-self.w].row, col = true };
				eraseBlocks[k-self.w-self.w] = { row = eraseBlocks[k-self.w-self.w].row, col = true };
				hasErase = true;
				--print("column "..j.." "..i.." k "..k);
			end
			
		end
		
	end
	
	
	local moveHandledList = {};
	local moveList = {};
	
	for k, v in ipairs(eraseBlocks) do
		
		local j, i = self:getPosByIndex(k);
		
		local typeInfo = "";
		if v.row then
			typeInfo = typeInfo.." row ";
		end
		
		if v.col then
			typeInfo = typeInfo.." col ";
		end
		
		if v.row or v.col then
			print("k "..k.." j "..j.." i "..i..typeInfo);
		end
		
		-- ͬʱ�����ƶ����б�
		if (v.row or v.col) and moveHandledList[k] == nil then
			
			moveHandledList[k] = true;
			
			-- �������ǵ�j�еģ�x������j����ô������һ�е�����
			-- �����ÿ������ƶ�
			local move = 0;
			for rowindex=self.h, 1, -1 do
				local tempkey = self:getIndexByPos(j, rowindex);
				--print("handle "..j.." "..rowindex.." tempkey "..tempkey);
				if eraseBlocks[tempkey].row or eraseBlocks[tempkey].col then
					-- ����������ĵ�ǰ�ƶ���1
					move = move + 1;
					moveHandledList[tempkey] = true;
				else
					-- �������ľ��ƶ���ǰ��move
					if move > 0 then
						-- ��������ƶ����x�� y
						table.insert(moveList, {x=j, y = rowindex + move, move = move});
						--print("1-- x "..j.." y "..(rowindex+move).." move "..move);
					end
				end
			end
			
			-- ���������Ķ����ɵ��ƶ��ĵ�������һ��move��
			for genNew = 1, move do
				table.insert(moveList, {x=j, y = genNew, move = move});
				--print("new-- x "..j.." y "..genNew.." move "..move);
			end
			
			
			--table.insert();
		end
				
	end
	
	--[[
	-- debug log
	for movekey, movevalue in ipairs(moveList) do
		print(" x "..movevalue.x.." y "..movevalue.y.." move "..movevalue.move);
	end
	--]]
	
	-- ����������block��λ������, û�еĻ�����nil
	if hasErase then
		
		-- k to pos
		local poslist = {};
		for k, v in ipairs(eraseBlocks) do
			if v.row or v.col then
				local x, y = self:getPosByIndex(k);
				
				table.insert(poslist, {x = x, y = y});
			end
		end
		
		return poslist, moveList;
	else
		return nil;
	end
	
end

function blocks:getIndexByPos(x, y)
	local k = (y-1) * self.w + x;
	
	return k;
end

function blocks:getPosByIndex(k)
	-- local k = (i-1) * self.w + j;
	
	local j = math.fmod(k-1, self.w) + 1; -- x �ڼ���
	
	local i = math.floor((k - j) / self.w) + 1; -- y �ڼ���
	
	return j, i;
end

-- �������������ģ��������������������µ�blocks��Ȼ��������Ӧ���ƶ�
function blocks:eraseAndGen(poslist)
	
	local movelist = {};
			
	for k, v in ipairs(poslist) do

		local x, y = v.x, v.y;
				
		for i=y, 1, -1 do
			if i == 1 then
				-- gen new
				self.data[x][i] = math.random(1, self.blockTyps);
			else
				--print("x "..x.." i "..i);
				self.data[x][i] = self.data[x][i-1];
			end
			
			--table.insert(movelist, {x = x, y = i});
		end
					
	end
		
	return movelist;
end


-- ����
function blocks:test()
	for i=1, self.h do
		
		for j=1, self.w do
			
			if i > 1 then
				print("swap i j "..i.." "..j.." --> "..(i-1).." "..j);
				self:swap(i, j, i-1, j);
				--self:printBlocks();
				
				local poslist = self:checkThree();
				
				local combo = 0;
				while poslist ~= nil do
					
					print("----combo-------  "..combo);
					self:printBlocks(poslist);
					
					local movelist = self:eraseAndGen(poslist);
					
					self:printBlocks(movelist);
					
					poslist = self:checkThree();
					
					combo = combo + 1;				
				end
				
				if combo == 0 then
					self:swap(i, j, i-1, j);
				end
				
				--[[
				if poslist ~= nil then
					
					self:printBlocks(poslist);
					
					local movelist = self:eraseAndGen(poslist);
					
					self:printBlocks(movelist);
					
					-- ����֮����Ҫ�ж������Ժ��ǲ������µ�����
					
				else
					self:swap(i, j, i-1, j);
				end
				--]]
				
			end
			
			
		end
		
	end
end

-- ��ӡblock
function blocks:printBlocks(poslist)
	local debuginfo = "\n";
	
	for i=1, self.h do
		
		for j=1, self.w do
			
			local inlist = false;
			if poslist then
				for k,v in pairs(poslist) do
					if v.x == j and v.y == i then
						inlist = true;
						break;
					end
				end
			end
			
			if not inlist then
				debuginfo = debuginfo..self.data[j][i].." ";
			else
				debuginfo = debuginfo.."*"..self.data[j][i].." ";
			end
		end
		
		debuginfo = debuginfo.."\n";
		
	end
	
	print(debuginfo);
	
end
