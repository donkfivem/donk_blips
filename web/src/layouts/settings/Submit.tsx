import { Button, Center } from '@mantine/core';
import { useStore } from '../../store';
import { useClipboard } from '../../store/clipboard';
import { useVisibility } from '../../store/visibility';
import { fetchNui } from '../../utils/fetchNui';

const Submit: React.FC = () => {
  const clipboard = useClipboard((state) => state.clipboard);
  const setVisible = useVisibility((state) => state.setVisible);

  const handleSubmit = () => {
    const data = { ...useStore.getState() };
    if (data.name === '') data.name = null;

    data.hideUi = data.hideUi || null;

    if (data.groups && data.groups.length > 0) {
      const groupsObj: { [key: string]: number } = {};

      for (let i = 0; i < data.groups.length; i++) {
        const groupField = data.groups[i];
        if (groupField.name && groupField.name !== '') groupsObj[groupField.name] = groupField.grade || 0;
      }

      // @ts-ignore
      data.groups = groupsObj;
    } // @ts-ignore
    else data.groups = null;

    setVisible(false);
    fetchNui('createBlip', data);
  };

  return (
    <Center>
      <Button color="blue" uppercase onClick={() => handleSubmit()} fullWidth>
        Confirm blip
      </Button>
    </Center>
  );
};

export default Submit;
