package com.bridgetec.common.osu.veloce;

import com.bridgetec.common.osu.veloce.ByteUtil;
import com.bridgetec.common.osu.veloce.SocketClient;

public class OSUBody_Ack_3020 extends OSUBody_3020 implements AckBody {
	
	private String result;
	private String msg;

	public static final String SUCCESS = "0000";
	public static final int BODY_LEN = 138;
	private int[] len = {2, 2, 2, 4, 128};
	
	@Override
	public String toString(){
		StringBuffer buff = new StringBuffer();
		buff.append("BODY=[\n");
		buff.append("\t SYSTEM ID    : ").append(getSystemId()).append("\n");
		buff.append("\t PROCESS ID   : ").append(getProcessId()).append("\n");
		buff.append("\t UPDATE TYPE  : ").append(getUpdateType()).append("\n");
		buff.append("\t RESULT       : ").append(result).append("\n");
		buff.append("\t MSG          : ").append(msg   ).append("\n");
		buff.append("]\n");
		return buff.toString();
	}
	
	@Override
	public Body clone(){
		OSUBody_Ack_3020 body = new OSUBody_Ack_3020();
		body.setSystemId(getSystemId());
		body.setProcessId(getProcessId());
		body.setUpdateType(getUpdateType());
		body.setResult(getResult());
		body.setResult(getMsg());
		return body;
	}
	
	public OSUBody_Ack_3020(){}
	
	public OSUBody_Ack_3020(byte[] data){
		toObject(data);
	}
	
	public OSUBody_Ack_3020(int byteOrder, byte[] data){
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
			ByteUtil.fillInBuff(buffer, startIdx            , len[idx  ], ByteUtil.short2byte( getSystemId()   ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], ByteUtil.short2byte( getProcessId()  ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], ByteUtil.short2byte( getUpdateType() ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], getResult()							 );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], getMsg()   							 );
		}
		else{
			ByteUtil.fillInBuff(buffer, startIdx            , len[idx  ], LEByteUtil.shortToByte( getSystemId()   ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], LEByteUtil.shortToByte( getProcessId()  ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], LEByteUtil.shortToByte( getUpdateType() ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], getResult()											 );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], getMsg()   											 );
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
			setSystemId	 	(ByteUtil.getshort(ByteUtil.getbytes(data, startIdx            , len[idx  ]), 0));
			setProcessId 	(ByteUtil.getshort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0));
			setUpdateType	(ByteUtil.getshort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0));
			setResult		(new String(       ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ])   ));
			setMsg			(new String(       ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ])   ));
		}
		else{
			setSystemId	 	(LEByteUtil.byteToShort(ByteUtil.getbytes(data, startIdx            , len[idx  ]), 0));
			setProcessId 	(LEByteUtil.byteToShort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0));
			setUpdateType	(LEByteUtil.byteToShort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0));
			setResult		(new String(						 ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ])   ));
			setMsg			(new String(						 ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ])   ));
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
