import React, { Fragment } from 'react';
import { ActionCableConsumer } from 'react-actioncable-provider';

const Cable = ({ currentCustomer, handleReceivedMessage }) => {
  return (
    <Fragment>
      <ActionCableConsumer
        channel={{ channel: 'FacebookMessagesChannel', id: currentCustomer }}
        onReceived={console.log("received")}
        onDisconnected={console.log("off")}
        onConnected={console.log("on")}
        onRejected={console.log('rejected')}
      />
    </Fragment>
  );
};

export default Cable;
