onmessage = function (e) {
    console.log('Worker: Message received from main script')
    postMessage(`from: ${e.data[1]}, to:main`)
}
