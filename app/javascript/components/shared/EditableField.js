import React, { Component } from "react";
import ContentEditable from 'react-contenteditable'

class EditableField extends Component {
   constructor(props) {
     super(props)
     this.contentEditable = React.createRef();
   }

    press = evt => {
     if (evt.key == 'Enter'){
       evt.preventDefault()      
       this.contentEditable.current.blur()
     }
   }

    render() {
      return (
       <ContentEditable
         innerRef={this.contentEditable}
         html={this.props.content} 
         disabled={false}
         onChange={e => this.props.handleInputChange(e, this.props.targetName)} 
         tagName='div'
         className= {this.props.givenClass ? this.props.givenClass : "editable_field" }
         onBlur={this.props.handlesubmit}
         onKeyDown={this.press}
         placeholder={this.props.placeholder}
       />
     )
   }
 }

  export default EditableField;
