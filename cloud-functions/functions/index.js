let functions = require('firebase-functions');

let admin = require('firebase-admin')
admin.initializeApp(functions.config().firebase)

exports.sendNotification = functions.database
	.ref('messages/{messageId}')
	.onWrite(event => {
	
	//.onCreate(event => {
		
		let message = event.data.val()
		sendNotification(message)
	})

	function sendNotification(message){
		let fromUser = message.fromUser
		let text = message.text
		let token = message.deviceToken

		let payload = {
			notification: {
				title: 'New message from ' + fromUser,
				body: text,
				sound: 'default'


			}
		}
		console.log(payload)
		
		//let topic = "newMessage"
		//admin.messaging().sendToTopic(topic, payload)
		admin.messaging().sendToDevice(token, payload)

	}


