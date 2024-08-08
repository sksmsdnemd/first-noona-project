package com.bridgetec.common.osu.veloce;

import com.bridgetec.common.osu.veloce.ByteUtil;
import com.bridgetec.common.osu.veloce.SocketClient;


public class OSUBody_Ack_2800 implements AckBody {
	
	private String result;
	private String msg;

	public static final String SUCCESS = "0000";
	public static final int BODY_LEN = 132;
	private int[] len = {4, 128};
	
	@Override
	public String toString(){
		StringBuffer buff = new StringBuffer();
		buff.append("BODY=[\n");
		buff.append("\t RESULT       : ").append(result).append("\n");
		buff.append("\t MSG           : ").append(msg).append("\n");
		buff.append("]\n");
		return buff.toString();
	}
	
	@Override
	public Body clone(){
		OSUBody_Ack_2800 body = new OSUBody_Ack_2800();
		body.setResult(result);
		body.setMsg(msg);
		return body;
	}
	
	public OSUBody_Ack_2800(){}
	
	public OSUBody_Ack_2800(byte[] data){
		toObject(data);
	}
	
	public OSUBody_Ack_2800(int byteOrder, byte[] data){
		toObject(byteOrder, data);
	}

	@Override
	public byte[] toByte(){
		return toByte(SocketClient.BYTE_ORDER_BIG);
	}
	
	@Override
	public byte[] toByte(int byteOrder){
		return toByte(byteOrder, new byte[BODY_LEN]);
	}
	
	@Override
	public byte[] toByte(int byteOrder, byte[] buffer){
		return toByte(byteOrder, buffer, 0);
	}
	
	@Override
	public byte[] toByte(int byteOrder, byte[] buffer, int offset){
		int idx = 0;
		int startIdx = offset;

		if( byteOrder == SocketClient.BYTE_ORDER_BIG ){
			ByteUtil.fillInBuff(buffer, startIdx            , len[idx  ], result);
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], msg);
		}
		else{
			ByteUtil.fillInBuff(buffer, startIdx            , len[idx  ], result);
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], msg);
		}
		
		return buffer;
	}
	
	@Override
	public void toObject(byte[] data){
		toObject(SocketClient.BYTE_ORDER_BIG, data);
	}
	
	@Override
	public void toObject(int byteOrder, byte[] data){
		int idx = 0;
		int startIdx = 0;
		
		if( byteOrder == SocketClient.BYTE_ORDER_BIG ){
			result 		= new String(ByteUtil.getbytes(data, startIdx            , len[idx  ])   );
			msg			= new String(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ])   );
		}
		else{
			result 		= new String(ByteUtil.getbytes(data, startIdx            , len[idx  ])   );
			msg			= new String(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ])   );
		}
	}
	
	@Override
	public int getBodyLen(){
		return BODY_LEN;
	}

	@Override
	public String getResult() {
		return result;
	}

	@Override
	public void setResult(String result) {
		this.result = result;
	}

	@Override
	public String getMsg() {
		return msg;
	}

	@Override
	public void setMsg(String msg) {
		this.msg = msg;
	}
	
}
