_G.love = require('love')

function lerp(v0, v1, t)
	return (1 - t) * v0 + t * v1;
end

function table_length_count(T)
	count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function aabb_collision(a, b) return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y end

function love.load()
	love.graphics.setBackgroundColor(0.2, 0.2, 0.2)

	love.graphics.setDefaultFilter("nearest", "nearest")
	tilesheet = {
		image = love.graphics.newImage("assets/tilesheet.png", { mipmaps = true }),
		width = 512,
		height = 384,
		tile_size = {
			width = 64,
			height = 64
		}
	}

	player = {
		x = window_settings.width / 2 - tilesheet.tile_size.width,
		y = window_settings.height - tilesheet.tile_size.height,
		angle = 0,
		speed = 10,
		velocity = { x = 0, y = 0 },
		sprite = love.graphics.newQuad(0 * tilesheet.tile_size.width, 0 * tilesheet.tile_size.height, tilesheet.tile_size.width, tilesheet.tile_size.height, tilesheet.width, tilesheet.height)
	}

	bullet = nil

	enimies = {}
	timer = 2
end

function love.update(dt)
	if player.x + tilesheet.tile_size.width < 0 then
		player.x = window_settings.width
	end

	if player.x - tilesheet.tile_size.width > window_settings.width then
		player.x = 0
	end

	if player.y + tilesheet.tile_size.height < 0 then
		player.y = window_settings.height
	end

	if player.y - tilesheet.tile_size.height > window_settings.height then
		player.y = 0
	end

	if love.keyboard.isDown('w') then
		dx = math.sin(math.rad(player.angle) * player.speed)
		dy = -math.cos(math.rad(player.angle) * player.speed)

		player.velocity.x = (player.velocity.x + player.speed * dx)
		player.velocity.y = (player.velocity.y + player.speed * dy)

		if player.velocity.y > 0 then
			player.velocity.y = math.min(player.velocity.y, 500)
		elseif player.velocity.y < 0 then
			player.velocity.y = math.max(player.velocity.y, -500)
		end

		if player.velocity.x > 0 then
			player.velocity.x = math.min(player.velocity.x, 500)
		elseif player.velocity.x < 0 then
			player.velocity.x = math.max(player.velocity.x, -500)
		end

		player.x = player.x + player.velocity.x * dt
		player.y = player.y + player.velocity.y * dt
	else
		if player.velocity.y > 0 then
			player.velocity.y = player.velocity.y - 600 * dt
			player.velocity.y = math.max(player.velocity.y, 0)
		else
			player.velocity.y = player.velocity.y + 600 * dt
			player.velocity.y = math.min(player.velocity.y, 0)
		end

		if player.velocity.x > 0 then
			player.velocity.x = player.velocity.x - 600 * dt
			player.velocity.x = math.max(player.velocity.x, 0)
		else
			player.velocity.x = player.velocity.x + 600 * dt
			player.velocity.x = math.min(player.velocity.x, 0)
		end

		player.x = player.x + player.velocity.x * dt
		player.y = player.y + player.velocity.y * dt
	end

	if love.keyboard.isDown('a') then
		player.angle = player.angle - dt * player.speed * 2

		dx = math.sin(math.rad(player.angle) * player.speed)
		dy = -math.cos(math.rad(player.angle) * player.speed)

		player.x = player.x + player.speed * dx * dt * 3
		player.y = player.y + player.speed * dy * dt * 3
	end

	if love.keyboard.isDown('d') then
		player.angle = player.angle + dt * player.speed * 2

		dx = math.sin(math.rad(player.angle) * player.speed)
		dy = -math.cos(math.rad(player.angle) * player.speed)

		player.x = player.x + player.speed * dx * dt * 19
		player.y = player.y + player.speed * dy * dt * 19
	end

	if love.keyboard.isDown('space') and not bullet then
		bullet = {
			x = player.x,
			y = player.y,
			angle = player.angle,
			speed = 10,
			velocity = { x = 0, y = 0 },
			sprite = love.graphics.newQuad(4 * tilesheet.tile_size.width, 3 * tilesheet.tile_size.height, tilesheet.tile_size.width, tilesheet.tile_size.height, tilesheet.width, tilesheet.height)
		}
	end

	if bullet then
		dx = math.sin(math.rad(bullet.angle) * bullet.speed)
		dy = -math.cos(math.rad(bullet.angle) * bullet.speed)

		bullet.x = bullet.x + bullet.speed * dx * dt * 90
		bullet.y = bullet.y + bullet.speed * dy * dt * 90

		if (bullet.x > window_settings.width or bullet.x < 0) or (bullet.y > window_settings.height or bullet.y < 0) then
			bullet = nil
		end
	end

	if bullet then
		for enemy in pairs(enimies) do
			if aabb_collision({ x = enimies[enemy].x, y = enimies[enemy].y, w = 16, h = 16 }, { x = bullet.x, y = bullet.y, w = 16, h = 16 }) then
				bullet = nil
				enimies[enemy] = nil
				break
			end

			if aabb_collision({ x = enimies[enemy].x, y = enimies[enemy].y, w = 32, h = 32 }, { x = player.x, y = player.y, w = 32, h = 32 }) then
				love.graphics.setColor(1, 1, 1)
				love.graphics.print("You fucked up!!", window_settings.width - 10, window_settings.height)
				os.exit(0)
			end
		end
	end

	if table_length_count(enimies) < 10 and timer < 0 then
		timer = 5
		table.insert(enimies, {
			x = math.random(0, window_settings.width) * math.random(-1, 1),
			y = math.random(0, window_settings.height) * math.random(-1, 1),
			angle = 0,
			speed = 10,
			lerp_speed = math.random(0.0009, 0.001),
			velocity = { x = 0, y = 0 },
			sprite = love.graphics.newQuad(math.random(0, 3) * tilesheet.tile_size.width, math.random(3, 4) * tilesheet.tile_size.height, tilesheet.tile_size.width, tilesheet.tile_size.height, tilesheet.width, tilesheet.height)
		})
	else
		timer = timer - dt
	end

	if table_length_count(enimies) ~= 0 then
		for element in pairs(enimies) do
			enimies[element].x = lerp(enimies[element].x, player.x, enimies[element].lerp_speed)
			enimies[element].y = lerp(enimies[element].y, player.y, enimies[element].lerp_speed)
		end
	end
end

function love.draw()
	love.graphics.draw(tilesheet.image, player.sprite, player.x, player.y, math.rad(player.angle) * player.speed)

	if bullet then
		love.graphics.draw(tilesheet.image, bullet.sprite, bullet.x, bullet.y, math.rad(bullet.angle) * bullet.speed)
	end

	if table_length_count(enimies) ~= 0 then
		for element in pairs(enimies) do
			if enimies[element].x > 0 and enimies[element].x < window_settings.width then
				love.graphics.draw(tilesheet.image, enimies[element].sprite, enimies[element].x, enimies[element].y)
			end
		end
	end
end
