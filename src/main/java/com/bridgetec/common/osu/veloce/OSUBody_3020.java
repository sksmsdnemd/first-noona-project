package com.bridgetec.common.osu.veloce;

import com.bridgetec.common.osu.veloce.ByteUtil;
import com.bridgetec.common.osu.veloce.LEByteUtil;
import com.bridgetec.common.osu.veloce.SocketClient;


public class OSUBody_3020 implements Body {
	
	public static final short UPDATE_TYPE_TEL_NO 		= (short)1;
	public static final short UPDATE_TYPE_COUNCEL_ID	= (short)2;

	private short systemId;
	private short processId;
	private short updateType;

	public final int BODY_LEN = 6;
	private int[] len = {2, 2, 2};
	
	@Override
	public String toString(){
		StringBuffer buff = new StringBuffer();
		buff.append("BODY=[\n");
		buff.append("\t SYSTEM ID    : ").append(getSystemId()).append("\n");
		buff.append("\t PROCESS ID   : ").append(getProcessId()).append("\n");
		buff.append("\t UPDATE TYPE  : ").append(getUpdateType()).append("\n");
		buff.append("]\n");
		return buff.toString();
	}
	
	@Override
	public Body clone(){
		OSUBody_3020 body = new OSUBody_3020();
		body.setSystemId(getSystemId());
		body.setProcessId(getProcessId());
		body.setUpdateType(getUpdateType());
		return body;
	}
	
	public OSUBody_3020(){}
	
	public OSUBody_3020(byte[] data){
		toObject(data);
	}
	
	public OSUBody_3020(int byteOrder, byte[] data){
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
		}
		else{
			ByteUtil.fillInBuff(buffer, startIdx            , len[idx  ], LEByteUtil.shortToByte( getSystemId()   ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], LEByteUtil.shortToByte( getProcessId()  ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], LEByteUtil.shortToByte( getUpdateType() ) );
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
		}
		else{
			setSystemId	 	(LEByteUtil.byteToShort(ByteUtil.getbytes(data, startIdx            , len[idx  ]), 0));
			setProcessId 	(LEByteUtil.byteToShort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0));
			setUpdateType	(LEByteUtil.byteToShort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0));
		}
	}
	
	@Override
	public int getBodyLen(){
		return BODY_LEN;
	}

	public short getSystemId() {
		return systemId;
	}

	public void setSystemId(short systemId) {
		this.systemId = systemId;
	}

	public short getProcessId() {
		return processId;
	}

	public void setProcessId(short processId) {
		this.processId = processId;
	}

	public short getUpdateType() {
		return updateType;
	}

	public void setUpdateType(short updateType) {
		this.updateType = updateType;
	}
}
