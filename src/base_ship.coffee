Body = Matter.Body
Bodies = Matter.Bodies
Vector3 = THREE.Vector3
Color = THREE.Color

class @BaseShip

  constructor: (options = {}) ->
    @rotationSpeed = 0.1
    @thrustPower = 0.0001
    @primaryFireRate = 200

    @primaryFireDelay = 0
    cube = new THREE.CubeGeometry(50, 20, 10)
    mat = new THREE.MeshLambertMaterial
      color: options.color || 0xff0000
      ambient: options.ambient || 0x330000
    @ship = new THREE.Mesh(cube, mat)
    @mesh = new THREE.Object3D()
    @mesh.add(@ship)
    @body = Bodies.trapezoid(100, 0, 20, 50, 0.5)
    @body.owner = @
    @primaryGunPower = 0.1

  update: (game) ->
    @ship.rotation.x += 0.1
    @firePrimary(game) if game.input.actions.primary
    @thrust(game) if game.input.actions.thrust
    @turnRight() if game.input.actions.right
    @turnLeft() if game.input.actions.left

  getAngle: ->
    angle = @body.angle - Math.PI / 2

  getShipVector: (offset) ->
    angle = @getAngle()
    {
      x: offset * Math.cos(angle)
      y: offset * Math.sin(angle)
    }

  thrust: (game) ->
    Body.applyForce(@body, {x: 0, y: 0}, @getShipVector(@thrustPower))
    offset = toThreeVector(@getShipVector(-30))
    position = toThreeVector(@body.position)
    game.partical.cone(position.add(offset), toThreeVector(@getShipVector(-3)), new Color(0x154492), 15)
    game.playSound 'thrust'

  turnRight: ->
    Body.rotate(@body, @rotationSpeed)

  turnLeft: ->
    Body.rotate(@body, -@rotationSpeed)

  firePrimary: (game) ->
    @primaryFireDelay -= game.physics.engine.timing.delta
    return if @primaryFireDelay > 0
    @primaryFireDelay = @primaryFireRate
    pos = @getShipVector(30)
    pos.x += @body.position.x
    pos.y += @body.position.y
    force = @getShipVector(0.005)
    game.add new Projectile(pos, force, game)
    game.playSound 'firePrimary'

  serialize: ->
    position: @body.position
    velocity: @body.velocity
    angle: @body.angle

  load: (data) ->
    Body.translate @body,
      x: data.position.x - @body.position.x
      y: data.position.y - @body.position.y
    Body.rotate @body, data.angle - @body.angle
    @body.velocity = data.velocity

