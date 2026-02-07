import axios from "@ohos/axios";

interface commands {
  commandslist: Array<string>
}

interface commandslistResponse {
  data: commands
}

const app = axios.create({
  baseURL: "http://172.21.223.159:8080/",
  timeout: 1000
})

export default async function getLinuxCommandList() {
  const response: commandslistResponse = await app.get('/commandslist');
  const commandslist: Array<string> = response.data.commandslist;
  return commandslist;
}