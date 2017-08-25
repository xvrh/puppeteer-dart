import 'dart:async';

class Session {

  Future send(String command, [Map parameters]) {

  }
}

/*
const debugProtocol = require('debug')('puppeteer:protocol');
const debugSession = require('debug')('puppeteer:session');

const EventEmitter = require('events');
const WebSocket = require('ws');

class Connection {
  /**
   * @param {string} url
   * @param {number=} delay
   * @return {!Promise<!Connection>}
   */
  static  create(url, delay = 0) async {
  return new Promise((resolve, reject) => {
  const ws = new WebSocket(url, { perMessageDeflate: false });
  ws.on('open', () => resolve(new Connection(url, ws, delay)));
  ws.on('error', reject);
  });
  }

  /**
   * @param {string} url
   * @param {!WebSocket} ws
   * @param {number=} delay
   */
  constructor(url, ws, delay = 0) {
  super();
  this._url = url;
  this._lastId = 0;
  /** @type {!Map<number, {resolve: function, reject: function, method: string}>}*/
  this._callbacks = new Map();
  this._delay = delay;

  this._ws = ws;
  this._ws.on('message', this._onMessage.bind(this));
  this._ws.on('close', this._onClose.bind(this));
  /** @type {!Map<string, !Session>}*/
  this._sessions = new Map();
  }

  /**
   * @return {string}
   */
  url() {
    return this._url;
  }

  /**
   * @param {string} method
   * @param {!Object=} params
   * @return {!Promise<?Object>}
   */
  send(method, params = {}) {
  const id = ++this._lastId;
  const message = JSON.stringify({id, method, params});
  debugProtocol('SEND ► ' + message);
  this._ws.send(message);
  return new Promise((resolve, reject) => {
  this._callbacks.set(id, {resolve, reject, method});
  });
  }

  /**
   * @param {string} message
   */
   _onMessage(message) async {
    if (this._delay)
      await new Promise(f => setTimeout(f, this._delay));
    debugProtocol('◀ RECV ' + message);
    const object = JSON.parse(message);
    if (object.id && this._callbacks.has(object.id)) {
    const callback = this._callbacks.get(object.id);
    this._callbacks.delete(object.id);
    if (object.error)
    callback.reject(new Error(`Protocol error (${callback.method}): ${object.error.message} ${object.error.data}`));
    else
    callback.resolve(object.result);
    } else {
    console.assert(!object.id);
    if (object.method === 'Target.receivedMessageFromTarget') {
    const session = this._sessions.get(object.params.sessionId);
    if (session)
    session._onMessage(object.params.message);
    } else if (object.method === 'Target.detachedFromTarget') {
    const session = this._sessions.get(object.params.sessionId);
    if (session)
    session._onClosed();
    this._sessions.delete(object.params.sessionId);
    } else {
    this.emit(object.method, object.params);
    }
    }
  }

  _onClose() {
    this._ws.removeAllListeners();
    for (const callback of this._callbacks.values())
    callback.reject(new Error(`Protocol error (${callback.method}): Target closed.`));
    this._callbacks.clear();
    for (const session of this._sessions.values())
    session._onClosed();
    this._sessions.clear();
  }

  /**
   * @return {!Promise}
   */
  dispose() {
    this._onClose();
    this._ws.close();
  }

  /**
   * @param {string} targetId
   * @return {!Promise<!Session>}
   */
   createSession(targetId) async {
    const {sessionId} = await this.send('Target.attachToTarget', {targetId});
    const session = new Session(this, targetId, sessionId);
    this._sessions.set(sessionId, session);
    return session;
    }
}

class Session {
  /**
   * @param {!Connection} connection
   * @param {string} targetId
   * @param {string} sessionId
   */
  constructor(connection, targetId, sessionId) {
    super();
    this._lastId = 0;
    /** @type {!Map<number, {resolve: function, reject: function, method: string}>}*/
    this._callbacks = new Map();
    this._connection = connection;
    this._targetId = targetId;
    this._sessionId = sessionId;
  }

  /**
   * @return {string}
   */
  targetId() {
    return this._targetId;
  }

  /**
   * @param {string} method
   * @param {!Object=} params
   * @return {!Promise<?Object>}
   */
  send(method, params = {}) {
  if (!this._connection)
  return Promise.reject(new Error(`Protocol error (${method}): Session closed. Most likely the page has been closed.`));
  const id = ++this._lastId;
  const message = JSON.stringify({id, method, params});
  debugSession('SEND ► ' + message);
  this._connection.send('Target.sendMessageToTarget', {sessionId: this._sessionId, message}).catch(e => {
  // The response from target might have been already dispatched.
  if (!this._callbacks.has(id))
  return;
  const callback = this._callbacks.get(id);
  this._callbacks.delete(object.id);
  callback.reject(e);
  });
  return new Promise((resolve, reject) => {
  this._callbacks.set(id, {resolve, reject, method});
  });
  }

  /**
   * @param {string} message
   */
  _onMessage(message) {
    debugSession('◀ RECV ' + message);
    const object = JSON.parse(message);
    if (object.id && this._callbacks.has(object.id)) {
      const callback = this._callbacks.get(object.id);
      this._callbacks.delete(object.id);
      if (object.error)
        callback.reject(new Error(`Protocol error (${callback.method}): ${object.error.message} ${object.error.data}`));
    else
    callback.resolve(object.result);
    } else {
    console.assert(!object.id);
    this.emit(object.method, object.params);
    }
  }

  /**
   * @return {!Promise}
   */
   dispose() async {
    await this._connection.send('Target.closeTarget', {targetId: this._targetId});
  }

  _onClosed() {
    for (const callback of this._callbacks.values())
    callback.reject(new Error(`Protocol error (${callback.method}): Target closed.`));
    this._callbacks.clear();
    this._connection = null;
  }
}

*/