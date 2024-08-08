package com.bridgetec.argo.service;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.stereotype.Service;

import com.bridgetec.argo.dao.ArgoDispatchDAO;
import com.bridgetec.argo.vo.ArgoDispatchServiceVo;

import egovframework.rte.fdl.cmmn.AbstractServiceImpl;

@Service("saLogService")
public class ArgoLogServiceImpl extends AbstractServiceImpl {
    private Logger            loMeLogger = LoggerFactory.getLogger(ArgoLogServiceImpl.class);
    
	@Resource(name = "ARGODB")
    private ArgoDispatchDAO argoLogDAO;
    
    public int logExcuteBefore(ArgoDispatchServiceVo saDispatchServiceVo, int seq) {
        if(saDispatchServiceVo.getAccessId() > 0 && !"ARGOCOMMON".equals(saDispatchServiceVo.getSvcName())) {
            saDispatchServiceVo.setSvcSeq(seq++);
            argoLogDAO.insertAccessLog(saDispatchServiceVo);
        }
        return seq;
    }
    
    public void logExcuteAfter(ArgoDispatchServiceVo saDispatchServiceVo) {
        if(saDispatchServiceVo.getAccessId() > 0)
        	argoLogDAO.updateAccessLog(saDispatchServiceVo);
    }
}
