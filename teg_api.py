import time
import requests
import json

LOCALHOST_ROOT = "http://localhost/api/"


class EpicGamerApi:
    # Question types
    Q_YES_NO = 0
    Q_AGREE_SPECTRUM = 1

    def __init__(self, api_key: str, url_root: str = LOCALHOST_ROOT) -> None:
        self._api_key = api_key
        self._url_root = url_root

    def list_funcs(self) -> str:
        data = {"api_key": self._api_key}
        url = f"{self._url_root}list_funcs"
        return requests.get(url, params=data).text

    def custom_call(self, model: str, method: str, data: dict = None) -> requests.Response:
        """
        :param model: model to run the method on
        :param method: some method of the model
        :param data: data to pass to the method as key-word arguments
        :return: raw server response
        """
        data = data if data else {}
        data["api_key"] = self._api_key
        url = f"{self._url_root}{model}.{method}"
        return requests.get(url, params=data)

    def call_on_json_file(self, model: str, method: str, filename: str, delay: float = 0) -> list[requests.Response]:
        """
        Calls EpicGamerApi.custom_call on each element of the list in given json file
        :param model: model to run the method on
        :param method: some method of the model
        :param filename: json file with a list of key-word argument dictionaries
        :param delay: (optional) delay between each request to api
        :return: all responses from all requests
        """
        with open(filename, "r") as file:
            datas = json.load(file)

        out = []

        for i, data in enumerate(datas):
            data["api_key"] = self._api_key
            ret = self.custom_call(model, method, data)
            print(f"{i} [{model}.{method}] => {ret.text}")
            out.append(ret)
            time.sleep(delay)

        return out
