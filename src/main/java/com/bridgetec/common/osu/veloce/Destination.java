package com.bridgetec.common.osu.veloce;

public class Destination {

	private String ip;
	private int port;
	private int systemId;
	private int processId;
	
	public Destination(){}
	
	@Override
	public Destination clone(){
		Destination dest = new Destination(ip, port, systemId, processId);
		return dest;
	}
	
	public Destination(String ip, int port, int systemId, int processId){
		this.ip = ip;
		this.port = port;
		this.systemId = systemId;
		this.processId = processId;
	}
	
	public String getIp() {
		return ip;
	}
	public Destination setIp(String ip) {
		this.ip = ip;
		return this;
	}
	public int getPort() {
		return port;
	}
	public Destination setPort(int port) {
		this.port = port;
		return this;
	}

	public int getSystemId() {
		return systemId;
	}

	public Destination setSystemId(int systemId) {
		this.systemId = systemId;
		return this;
	}

	public int getProcessId() {
		return processId;
	}

	public Destination setProcessId(int processId) {
		this.processId = processId;
		return this;
	}
}
