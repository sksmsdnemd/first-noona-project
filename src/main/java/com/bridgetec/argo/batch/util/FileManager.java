package com.bridgetec.argo.batch.util;

import java.io.File;

/**
 * =======================================================
 * 설명 : 파일조작용 유틸
 * =======================================================
 */
public class FileManager {
	/**
	 * 파일을 이동하는 처리
	 * @param oriPath 원본위치
	 * @param desPath 이동위치
	 * @return
	 */
	public static boolean moveFile(File oriFile, File desFile) {
		File desDir = new File(desFile.getParent());
		if (!desDir.exists()) {
			desDir.mkdir();
		}
		if (oriFile.renameTo(desDir)) {
			return true;
		}
		return false;
	}
	
	/**
	 * 파일을 이동하는 처리
	 * @param oriPath 원본위치
	 * @param desPath 이동위치
	 * @return
	 */
	public static boolean moveFile(String oriPath, String desPath) {
		File file = new File(oriPath);
		File desFile = new File(desPath);
		File desDir = desFile.getParentFile();
		if (!desDir.exists()) {
			desDir.mkdirs();
		}
		if (desFile.exists()) {
			desFile.delete();
		}
		if (file.renameTo(desFile)) {
			return true;
		}
		return false;
	}
	
	/**
	 * 파일을 이동하는 처리
	 * ※ 같은 파일이 존재할 경우, 기존 파일을 삭제할 지 여부를 설정
	 * @param oriPath 원본위치
	 * @param desPath 이동위치
	 * @param deleteFlg 동일 파일 삭제여부
	 * @return
	 */
	public static boolean moveFile(File oriPath, File desPath, boolean deleteFlg) {
		if (oriPath != null && desPath != null) {
			if (deleteFlg && desPath.exists()) {
				desPath.delete();
			}
			if (oriPath.renameTo(desPath)) {
				return true;	
			}
		}
		return false;
	}
	
	public static boolean moveFile(File oriPath, File desPathwithFileName, File desPath) {
		if (oriPath != null && desPath != null) {
			if (!desPath.isDirectory()) {
				desPath.mkdirs();
			}
			if (oriPath.renameTo(desPathwithFileName)) {
				return true;
			}
		}
		return false;
	}
	
	public static boolean moveFile(File oriPath, File desPathwithFileName, File desPath, boolean deleteFlg) {
		if (oriPath != null && desPath != null) {
			if (deleteFlg && desPathwithFileName.exists()) {
				desPathwithFileName.delete();
			}
			if (!desPath.isDirectory()) {
				desPath.mkdirs();
			}
			if (oriPath.renameTo(desPathwithFileName)) {
				return true;
			}
		}
		return false;
	}
}
