import _ from 'https://cdn.skypack.dev/lodash'
# import {ass} from '../js/utils.js'

SIZE = 50

numbers = [24,8,10,20,5,15]
target = 497

operators = "+ - * /".split ' '
numberButtons = []
operatorButtons = []
undoButton = null
buttons = []
history = []

marked = []

start = new Date()

getMarked = () =>
	[a,b] = [marked[0].text,marked[1].text]
	if a < b then [b,a] else [a,b]

setActive = =>
	if marked.length == 2
		operatorButtons[0].active = true
		operatorButtons[1].active = true
		operatorButtons[2].active = true
		[a,b] = getMarked()
		operatorButtons[3].active = a%%b==0
	else
		for button in operatorButtons
			button.active = false

class Button
	constructor : (@text,@x,@y,@active) ->
	draw : =>
		if @text == "" then return
		push()
		fill if @ in marked then 'green' else 'white'
		circle @x,@y,SIZE
		fill if @active then 'black' else 'lightgray'
		textSize [40,30,30,25,20,15,12,10,8,6,5,4,3,2][str(@text).length]
		text @text,@x,@y+3
		pop()
	inside : (mx,my) =>
		dx = mx-@x
		dy = my-@y
		dx*dx + dy*dy < SIZE/2 * SIZE/2
	mark : =>
		marked.push @
		if marked.length > 2 then marked.shift()

class UndoButton extends Button
	click : =>
		if history.length == 0 then return
		[c,a,text,b,texter] = history.pop()
		for text,i in texter
			numberButtons[i].text = text
		marked = []
		setActive()
		@active = history.length > 0
		return

class NumberButton extends Button
	click : =>
		@mark()
		setActive()

class OperatorButton extends Button
	click : =>
		if marked.length == 2
			[a,b] = getMarked()
			c = 0
			if @text == '+' then c =a+b
			if @text == '-' then c =a-b
			if @text == '*' then c =a*b
			if @text == '/' and a%%b==0 then c =a//b
			if c > 0
				texter = _.map numberButtons, (b) => b.text
				history.push [c,a,@text,b,texter]
				marked[0].text = ""
				marked[1].text = c
				marked.shift()
				undoButton.active = history.length > 0

window.setup = =>
	createCanvas 600,300
	noLoop()
	textAlign CENTER,CENTER
	textSize 30

	for number,i in numbers
		x = 100+10 + i%3 * (SIZE+10)
		y = 100 + i//3 * (SIZE+10)
		numberButtons.push new NumberButton number,x,y,true

	y = 225
	for operator,i in operators
		x = 50 + i%4 * (SIZE+10)
		operatorButtons.push new OperatorButton operator,x,y,false

	x = 95 + 4 * SIZE
	undoButton = new UndoButton 'undo',x,y,false

	buttons = [numberButtons..., operatorButtons..., undoButton]
	console.log buttons

window.mousePressed = =>
	for button in buttons
		if button.inside mouseX,mouseY
			button.click()
			draw()

window.draw = =>
	background 'gray'
	for button in buttons
		button.draw()
	push()
	textSize 50
	text target,175,45
	pop()
	drawHistory()

drawHistory = =>
	push()
	textSize 30
	for item,i in history
		[c,a,op,b] = item
		text "#{c} = #{a} #{op} #{b}", 450, 40 + i*40
	pop()
	if history.length == 0 then return
	if _.last(history)[0] == target
		push()
		textSize 30
		text "Well done!", 450, 40 + history.length*40
		textSize 20
		text "#{(new Date() - start)} ms", 450, 80 + history.length*40
		pop()
