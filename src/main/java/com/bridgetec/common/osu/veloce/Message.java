package com.bridgetec.common.osu.veloce;

import com.bridgetec.common.osu.veloce.SocketClient;

public class Message {
	
	private Header header;
	private Body body;
	private Class<?> ackBody;
	private Destination destination;
	
	@Override
	public String toString(){
		StringBuffer buff = new StringBuffer();
		
		if( header != null ) buff.append(header.toString());
		if( body != null ) buff.append(body.toString());
		
		return buff.toString();
	}
	
	@Override
	public Message clone(){
		Message msg = new Message(header.clone(), body.clone(), ackBody, destination.clone());
		return msg;
	}
	
	public Message(){
		
	}
	
	public Message(Header header){
		this(header, null);
	}
	
	public Message(Body body){
		this(null, body);
	}
	
	public Message(Header header, Body body){
		this(header, body, null, null);
	}
	
	public Message(Header header, Body body, Class<?> ackBody){
		this(header, body, ackBody, null);
	}
	
	public Message(Header header, Body body, Destination destination){
		this(header, body, null, destination);
	}
	
	public Message(Header header, Body body, Class<?> ackBody, Destination destination){
		this.header	 		= header;
		this.body 			= body;
		this.ackBody 		= ackBody;
		this.destination 	= destination;
	}
	
	public byte[] toByte(){
		return toByte(SocketClient.BYTE_ORDER_BIG);
	}
	
	public byte[] toByte(int byteOrder){
		byte[] buffer = new byte[header.getHeaderLen()+body.getBodyLen()];
		header.toByte(byteOrder, buffer, 0);
		body.toByte(byteOrder, buffer, header.getHeaderLen());
		return buffer;
	}
	
	public Header getHeader() {
		return header;
	}
	public void setHeader(Header header) {
		this.header = header;
	}
	public Body getBody() {
		return body;
	}
	public void setBody(Body body) {
		this.body = body;
	}

	public Destination getDestination() {
		return destination;
	}

	public void setDestination(Destination destination) {
		this.destination = destination;
	}

	public Class<?> getAckBody() {
		return ackBody;
	}

	public void setAckBody(Class<?> ackBody) {
		this.ackBody = ackBody;
	}
}
