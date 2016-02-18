player = {
	x = 0,
	y = 0,
	model = nil,
	angle = 270,
	angle_speed = 0,
	angle_speed_max = 30*3.1415/180,
	can_shoot = true,
	can_shoot_timer_max = 0.2,
	can_shoot_timer = 0.2,
	speed = {
		x = 0,
		y = 0,
		max = 500
		}
	}

bullets = {}
bullet_model = nil

asteroids = {}
asteroid_model = nil
asteroid_spawn_timer = 1
asteroid_spawn_timer_max = 1

score = 0

function fire()
	new_bullet = {
		x = player.x,
		y = player.y,
		angle = player.angle,
		speed = {
			x = player.speed.x + math.cos(math.rad(player.angle))*10,
			y = player.speed.y + math.sin(math.rad(player.angle))*10
		},
		lifetime = 0,
		lifetime_max = 3
	}
	table.insert(bullets, new_bullet)
end

function spawn_asteroid()
	new_asteroid = {
		x = (math.random()-math.random()),
		y = (math.random()-math.random()),
		angle = math.rad(math.random(0, 360)),
		lifetime = 0,
		lifetime_max = 60
	}
	if new_asteroid.x > 0 then
		new_asteroid.x = new_asteroid.x*100 + player.x + 400
	else
		new_asteroid.x = new_asteroid.x*100 + player.x - 400
	end
	if new_asteroid.y > 0 then
		new_asteroid.y = new_asteroid.y*100 + player.y + 300
	else
		new_asteroid.y = new_asteroid.y*100 + player.y - 300
	end
	table.insert(asteroids, new_asteroid)
end

function a_b_c(a, b)
	return a.x - 25 < b.x and
		   b.x < a.x + 25 and
		   a.y -25 < b.y and
		   b.y < a.y +25
end

function love.load()
	player.model = love.graphics.newCanvas(30, 30)
	love.graphics.setCanvas(player.model)
		love.graphics.clear()
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.setLineWidth(2)
		love.graphics.line(0,30, 15,0, 30,30, 0,30)
	bullet_model = love.graphics.newCanvas(3,5)
	love.graphics.setCanvas(bullet_model)
		love.graphics.clear()
		love.graphics.setColor(255, 255, 0, 255)
		love.graphics.setLineWidth(2)
		love.graphics.line(2, 0, 2, 5)
	asteroid_model = love.graphics.newCanvas(50, 50)
	love.graphics.setCanvas(asteroid_model)
		love.graphics.clear()
		love.graphics.setColor(100, 100, 100, 255)
		love.graphics.circle('fill', 25, 25, 25, 15)
		love.graphics.setColor(50, 50, 50, 255)
		love.graphics.circle('fill', 20, 30, 5, 15)
		love.graphics.circle('fill', 30, 10, 5, 15)
		love.graphics.circle('fill', 40, 25, 5, 15)
	love.graphics.setCanvas()
	love.graphics.setColor(255, 255, 255, 255)
end

fps = 0

function love.update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	
	if love.keyboard.isDown('left') then
		player.angle = player.angle - 5
	end
	if love.keyboard.isDown('right') then
		player.angle = player.angle + 5
	end
	if love.keyboard.isDown('up') then
		player.speed.x = player.speed.x + math.cos(math.rad(player.angle))*dt
		player.speed.y = player.speed.y + math.sin(math.rad(player.angle))*dt
	end
	player.x = player.x + player.speed.x
	player.y = player.y + player.speed.y
	
	player.can_shoot_timer = player.can_shoot_timer - (1*dt)
	if player.can_shoot_timer < 0 then
		player.can_shoot = true
	end
	
	asteroid_spawn_timer = asteroid_spawn_timer - (1*dt)
	if (asteroid_spawn_timer < 0) then
		asteroid_spawn_timer = asteroid_spawn_timer_max
		spawn_asteroid()
	end
	
	if love.keyboard.isDown('space', ' ') and player.can_shoot then
		fire()
		player.can_shoot = false
		player.can_shoot_timer = player.can_shoot_timer_max
	end
	
	for i, bullet in ipairs(bullets) do
		bullet.x = bullet.x + bullet.speed.x
		bullet.y = bullet.y + bullet.speed.y
		bullet.lifetime = bullet.lifetime + (1*dt)
		if bullet.lifetime > bullet.lifetime_max then
			table.remove(bullets, i)
		end
	end
	
	for i, asteroid in ipairs(asteroids) do
		asteroid.lifetime = asteroid.lifetime + (1*dt)
		if asteroid.lifetime > asteroid.lifetime_max then
			table.remove(asteroids, i)
		end
	end
	
	for i, asteroid in ipairs(asteroids) do
		for j, bullet in ipairs(bullets) do
			if a_b_c(asteroid, bullet) then
				table.remove(bullets, j)
				table.remove(asteroids, i)
				score = score + 1
			end
		end
	end
	fps = 1/dt
end

function love.draw()
	love.graphics.translate(400-player.x, 300-player.y)
	love.graphics.clear(0, 0, 0, 255)
	love.graphics.print('SCORE: '..tostring(score), -390+player.x, -290+player.y)
	love.graphics.print('x: '..tostring(player.x), -390+player.x, -270+player.y)
	love.graphics.print('y: '..tostring(player.y), -390+player.x, -260+player.y)
	
	love.graphics.draw(player.model, player.x, player.y, math.rad(player.angle+90), 1,1, 15, 15)
	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet_model, bullet.x, bullet.y, math.rad(bullet.angle+90), 1,1, 2, 3)
	end
	for i,asteroid in ipairs(asteroids) do
		love.graphics.draw(asteroid_model, asteroid.x, asteroid.y, asteroid.angle, 1,1, 25, 25)
	end
	
end