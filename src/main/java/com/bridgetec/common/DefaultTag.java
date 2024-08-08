package com.bridgetec.common;


import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.BodyTagSupport;

public class DefaultTag extends BodyTagSupport {

    private String var;
    private Object value;

    //for tag attribute
    public void setVar(String var) {
        this.var = var;
    }

    //for tag attribute
    public void setValue(Object value) {
        this.value = value;
    }

    public int doEndTag() throws JspException {
        Object oldValue = pageContext.getAttribute(var);
        Object newValue;

        if(value != null) {
            newValue = value;
        }

        else {
            if(bodyContent == null || bodyContent.getString() == null) {
                newValue = "";
            }

            else {
                newValue = bodyContent.getString().trim();
            }
        }

        if(oldValue == null) {
            pageContext.setAttribute(var, newValue);
        }

        else if(oldValue.toString().trim().length() == 0) {
            pageContext.setAttribute(var, newValue);
        }

        return EVAL_PAGE;
    }
}