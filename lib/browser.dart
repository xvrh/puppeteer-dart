import 'dart:async';
import 'package:meta/meta.dart';
import 'package:puppeteer_dart/src/connection.dart';
/*
class Browser {
  final Connection _connection;
  final bool ignoreHttpsErrors;
  final Function closeCallback;

  Browser(this._connection, {this.ignoreHttpsErrors: false, @required this.closeCallback}) {
    this._screenshotTaskQueue = new TaskQueue();
  }

  String get wsEndpoint => _connection.url;
/*
   Future<Page> newPage() async {
    const {targetId} = await this._connection.send('Target.createTarget', {url: 'about:blank'});
    const client = await this._connection.createSession(targetId);
    return await Page.create(client, this._ignoreHTTPSErrors, this._screenshotTaskQueue);
  }
*/
  /**
   * @return {!Promise<string>}
   */
  Future<String> version() async {
    final Map<String, String> version = await this._connection.send('Browser.getVersion');
    return version['product'];
  }

  close() {
    this._connection.dispose();
    this._closeCallback.call(null);
  }
}

class TaskQueue {
  constructor() {
    this._chain = Promise.resolve();
  }

  /**
   * @param {function()} task
   * @return {!Promise}
   */
  postTask(task) {
    const result = this._chain.then(task);
    this._chain = result.catch(() => {});
    return result;
  }
}
*/